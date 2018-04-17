" ============================================================================
" CLASS: Creator
"
" This class is responsible for creating MDTree instances.  The new MDTree
" may be a tab tree, a window tree, or a mirrored tree.  In the process of
" creating a MDTree, it sets up all of the window and buffer options and key
" mappings etc.
" ============================================================================


let s:Creator = {}
let g:MDTreeCreator = s:Creator

" FUNCTION: s:Creator._bindMappings() {{{1
function! s:Creator._bindMappings()
    "make <cr> do the same as the activate node mapping
    nnoremap <silent> <buffer> <cr> :call nerdtree#ui_glue#invokeKeyMap(g:MDTreeMapActivateNode)<cr>

    call g:MDTreeKeyMap.BindAll()
endfunction

" FUNCTION: s:Creator._broadcastInitEvent() {{{1
function! s:Creator._broadcastInitEvent()
    silent doautocmd User MDTreeInit
endfunction

" FUNCTION: s:Creator.BufNamePrefix() {{{2
function! s:Creator.BufNamePrefix()
    return 'NERD_tree_'
endfunction

" FUNCTION: s:Creator.CreateTabTree(a:name) {{{1
function! s:Creator.CreateTabTree(name)
    let creator = s:Creator.New()
    call creator.createTabTree(a:name)
endfunction

" FUNCTION: s:Creator.createTabTree(a:name) {{{1
" name: the name of a bookmark or a directory
function! s:Creator.createTabTree(name)
    let l:path = self._pathForString(a:name)

    " Abort if an exception was thrown (i.e., if the bookmark or directory
    " does not exist).
    if empty(l:path)
        return
    endif

    " Obey the user's preferences for changing the working directory.
    if g:MDTreeChDirMode != 0
        call l:path.changeToDir()
    endif

    if g:MDTree.ExistsForTab()
        call g:MDTree.Close()
        call self._removeTreeBufForTab()
    endif

    call self._createTreeWin()
    call self._createMDTree(l:path, 'tab')
    call b:MDTree.render()
    call b:MDTree.root.putCursorHere(0, 0)

    call self._broadcastInitEvent()
endfunction

" FUNCTION: s:Creator.CreateWindowTree(dir) {{{1
function! s:Creator.CreateWindowTree(dir)
    let creator = s:Creator.New()
    call creator.createWindowTree(a:dir)
endfunction

" FUNCTION: s:Creator.createWindowTree(dir) {{{1
function! s:Creator.createWindowTree(dir)
    try
        let path = g:MDTreePath.New(a:dir)
    catch /^MDTree.InvalidArgumentsError/
        call nerdtree#echo("Invalid directory name:" . a:name)
        return
    endtry

    "we want the directory buffer to disappear when we do the :edit below
    setlocal bufhidden=wipe

    let previousBuf = expand("#")

    "we need a unique name for each window tree buffer to ensure they are
    "all independent
    exec g:MDTreeCreatePrefix . " edit " . self._nextBufferName()

    call self._createMDTree(path, "window")
    let b:MDTree._previousBuf = bufnr(previousBuf)
    call self._setCommonBufOptions()

    call b:MDTree.render()

    call self._broadcastInitEvent()
endfunction

" FUNCTION: s:Creator._createMDTree(path) {{{1
function! s:Creator._createMDTree(path, type)
    let b:MDTree = g:MDTree.New(a:path, a:type)

    " TODO: This assignment is kept for compatibility reasons.  Many other
    " plugins use "b:MDTreeRoot" instead of "b:MDTree.root".  Remove this
    " assignment in the future.
    let b:MDTreeRoot = b:MDTree.root

    call b:MDTree.root.open()
endfunction

" FUNCTION: s:Creator.CreateMirror() {{{1
function! s:Creator.CreateMirror()
    let creator = s:Creator.New()
    call creator.createMirror()
endfunction

" FUNCTION: s:Creator.createMirror() {{{1
function! s:Creator.createMirror()
    "get the names off all the nerd tree buffers
    let treeBufNames = []
    for i in range(1, tabpagenr("$"))
        let nextName = self._tabpagevar(i, 'MDTreeBufName')
        if nextName != -1 && (!exists("t:MDTreeBufName") || nextName != t:MDTreeBufName)
            call add(treeBufNames, nextName)
        endif
    endfor
    let treeBufNames = self._uniq(treeBufNames)

    "map the option names (that the user will be prompted with) to the nerd
    "tree buffer names
    let options = {}
    let i = 0
    while i < len(treeBufNames)
        let bufName = treeBufNames[i]
        let treeRoot = getbufvar(bufName, "MDTree").root
        let options[i+1 . '. ' . treeRoot.path.str() . '  (buf name: ' . bufName . ')'] = bufName
        let i = i + 1
    endwhile

    "work out which tree to mirror, if there is more than 1 then ask the user
    let bufferName = ''
    if len(keys(options)) > 1
        let choices = ["Choose a tree to mirror"]
        let choices = extend(choices, sort(keys(options)))
        let choice = inputlist(choices)
        if choice < 1 || choice > len(options) || choice ==# ''
            return
        endif

        let bufferName = options[sort(keys(options))[choice-1]]
    elseif len(keys(options)) ==# 1
        let bufferName = values(options)[0]
    else
        call nerdtree#echo("No trees to mirror")
        return
    endif

    if g:MDTree.ExistsForTab() && g:MDTree.IsOpen()
        call g:MDTree.Close()
    endif

    let t:MDTreeBufName = bufferName
    call self._createTreeWin()
    exec 'buffer ' .  bufferName
    if !&hidden
        call b:MDTree.render()
    endif
endfunction

" FUNCTION: s:Creator._createTreeWin() {{{1
" Inits the NERD tree window. ie. opens it, sizes it, sets all the local
" options etc
function! s:Creator._createTreeWin()
    "create the nerd tree window
    let splitLocation = g:MDTreeWinPos ==# "left" ? "topleft " : "botright "
    let splitSize = g:MDTreeWinSize

    if !g:MDTree.ExistsForTab()
        let t:MDTreeBufName = self._nextBufferName()
        silent! exec splitLocation . 'vertical ' . splitSize . ' new'
        silent! exec "edit " . t:MDTreeBufName
    else
        silent! exec splitLocation . 'vertical ' . splitSize . ' split'
        silent! exec "buffer " . t:MDTreeBufName
    endif

    setlocal winfixwidth
    call self._setCommonBufOptions()
endfunction

" FUNCTION: s:Creator._isBufHidden(nr) {{{1
function! s:Creator._isBufHidden(nr)
    redir => bufs
    silent ls!
    redir END

    return bufs =~ a:nr . '..h'
endfunction

" FUNCTION: s:Creator.New() {{{1
function! s:Creator.New()
    let newCreator = copy(self)
    return newCreator
endfunction

" FUNCTION: s:Creator._nextBufferName() {{{2
" returns the buffer name for the next nerd tree
function! s:Creator._nextBufferName()
    let name = s:Creator.BufNamePrefix() . self._nextBufferNumber()
    return name
endfunction

" FUNCTION: s:Creator._nextBufferNumber() {{{2
" the number to add to the nerd tree buffer name to make the buf name unique
function! s:Creator._nextBufferNumber()
    if !exists("s:Creator._NextBufNum")
        let s:Creator._NextBufNum = 1
    else
        let s:Creator._NextBufNum += 1
    endif

    return s:Creator._NextBufNum
endfunction

" FUNCTION: s:Creator._pathForString(str) {{{1
" find a bookmark or adirectory for the given string
function! s:Creator._pathForString(str)
    let path = {}
    if g:MDTreeBookmark.BookmarkExistsFor(a:str)
        let path = g:MDTreeBookmark.BookmarkFor(a:str).path
    else
        let dir = a:str ==# '' ? getcwd() : a:str

        "hack to get an absolute path if a relative path is given
        if dir =~# '^\.'
            let dir = getcwd() . g:MDTreePath.Slash() . dir
        endif
        let dir = g:MDTreePath.Resolve(dir)

        try
            let path = g:MDTreePath.New(dir)
        catch /^MDTree.InvalidArgumentsError/
            call nerdtree#echo("No bookmark or directory found for: " . a:str)
            return {}
        endtry
    endif
    if !path.isDirectory
        let path = path.getParent()
    endif

    return path
endfunction

" Function: s:Creator._removeTreeBufForTab()   {{{1
function! s:Creator._removeTreeBufForTab()
    let buf = bufnr(t:MDTreeBufName)

    "if &hidden is not set then it will already be gone
    if buf != -1

        "nerdtree buf may be mirrored/displayed elsewhere
        if self._isBufHidden(buf)
            exec "bwipeout " . buf
        endif

    endif

    unlet t:MDTreeBufName
endfunction

" FUNCTION: s:Creator._setCommonBufOptions() {{{1
function! s:Creator._setCommonBufOptions()
    "throwaway buffer options
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal foldmethod=manual
    setlocal nofoldenable
    setlocal nobuflisted
    setlocal nospell
    if g:MDTreeShowLineNumbers
        setlocal nu
    else
        setlocal nonu
        if v:version >= 703
            setlocal nornu
        endif
    endif

    iabc <buffer>

    if g:MDTreeHighlightCursorline
        setlocal cursorline
    endif

    call self._setupStatusline()
    call self._bindMappings()
    setlocal filetype=nerdtree
endfunction

" FUNCTION: s:Creator._setupStatusline() {{{1
function! s:Creator._setupStatusline()
    if g:MDTreeStatusline != -1
        let &l:statusline = g:MDTreeStatusline
    endif
endfunction

" FUNCTION: s:Creator._tabpagevar(tabnr, var) {{{1
function! s:Creator._tabpagevar(tabnr, var)
    let currentTab = tabpagenr()
    let old_ei = &ei
    set ei=all

    exec "tabnext " . a:tabnr
    let v = -1
    if exists('t:' . a:var)
        exec 'let v = t:' . a:var
    endif
    exec "tabnext " . currentTab

    let &ei = old_ei

    return v
endfunction

" FUNCTION: s:Creator.ToggleTabTree(dir) {{{1
function! s:Creator.ToggleTabTree(dir)
    let creator = s:Creator.New()
    call creator.toggleTabTree(a:dir)
endfunction

" FUNCTION: s:Creator.toggleTabTree(dir) {{{1
" Toggles the NERD tree. I.e the NERD tree is open, it is closed, if it is
" closed it is restored or initialized (if it doesnt exist)
"
" Args:
" dir: the full path for the root node (is only used if the NERD tree is being
" initialized.
function! s:Creator.toggleTabTree(dir)
    if g:MDTree.ExistsForTab()
        if !g:MDTree.IsOpen()
            call self._createTreeWin()
            if !&hidden
                call b:MDTree.render()
            endif
            call b:MDTree.ui.restoreScreenState()
        else
            call g:MDTree.Close()
        endif
    else
        call self.createTabTree(a:dir)
    endif
endfunction

" Function: s:Creator._uniq(list)   {{{1
" returns a:list without duplicates
function! s:Creator._uniq(list)
  let uniqlist = []
  for elem in a:list
    if index(uniqlist, elem) ==# -1
      let uniqlist += [elem]
    endif
  endfor
  return uniqlist
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
