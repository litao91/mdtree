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

function! s:Creator._bindMappings()
    nnoremap <silent> <buffer> <cr> :call mdtree#ui_glue#invokeKeyMap(g:MDTreeMapActivateNode)<cr>
    call g:MDTreeKeyMap.BindAll()
endfunction
    
function! s:Creator.createTabTree(name)
    let l:path = self._pathForString(a:name)

    if empty(l:path)
        return
    endif

    if g:MDTree.ExistsForTab()
        call g:MDTree.Close()
        call self._removeTreeBufForTab()
    endif
    call self._createTreeWin()
    call self._createMDTree(l:path, 'tab')
    call b:MDTree.render()
endfunction

function! s:Creator._createMDTree(path, type)
    let b:MDTree = g:MDTree.New(a:path, a:type)
    let b:MDTreeRoot = b:MDTree.root

    call b:MDTree.root.open()
endfunction

function! s:Creator._removeTreeBufForTab()
    let buf = bufnr(t:MDTreeBufName)
    if buf != -1
        if self._isBufHidden(buf)
            exec "bwipeout " . buf
        endif
    endif
    unlet t:MDTreeBufName
endfunction

function! s:Creator._isBufHidden(nr)
    redir => bufs
    silent ls!
    redir END
    return bufs =~a:nr . '..h'
endfunction

" FUNCTION: s:Creator.ToggleTabTree(dir) {{{1
function! s:Creator.ToggleTabTree(dir)
    let creator = s:Creator.New()
    call creator.toggleTabTree(a:dir)
endfunction

" FUNCTION: s:Creator._createTreeWin() {{{1
" Init the window. ie. opens it, sizes it, sets all the local
" options etc
function! s:Creator._createTreeWin()
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
    setlocal nonu
    iabc <buffer>
    setlocal cursorline
    " call self._setupStatusline()
    call self._bindMappings()
    setlocal filetype=mdtree
endfunction


" FUNCTION: s:Creator.New() {{{1
function! s:Creator.New()
    let newCreator = copy(self)
    return newCreator
endfunction

" FUNCTION: s:Creator._nextBufferName() {{{2
" return the buffer name for the next mdtree
function! s:Creator._nextBufferName()
    let name = s:Creator.BufNamePrefix() . self._nextBufferNumber()
    return name
endfunction

" FUNCTION: s:Creator._pathForString(str) {{{1
" Find a directory for the given string
function! s:Creator._pathForString(str)
    let path = {}
    let dir = a:str ==# '' ? getcwd() : a:str
    " hack to get an absolute path
    if dir =~# '^\.'
        let dir = getcwd() . g:MDTreePath.Slash() . dir
    endif
    let dir = g:MDTreePath.Resolve(dir)

    try 
        let path = g:MDTreePath.New(dir)
    catch /^MDTree.InvalidArgumentsError/
        call mdtree#echo("No directory found for " . a:str)
        return {}
    endtry
    if !path.isDirectory
        let path = path.getParent()
    endif
    return path
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

" FUNCTION: s:Creator.BufNamePrefix() {{{2
function! s:Creator.BufNamePrefix()
    return 'MD_tree_'
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

" vim: set sw=4 sts=4 et fdm=marker:
