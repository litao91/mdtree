"CLASS: MDTree
"============================================================
let s:MDTree = {}
let g:MDTree = s:MDTree

"FUNCTION: s:MDTree.AddPathFilter() {{{1
function! s:MDTree.AddPathFilter(callback)
    call add(s:MDTree.PathFilters(), a:callback)
endfunction

"FUNCTION: s:MDTree.changeRoot(node) {{{1
function! s:MDTree.changeRoot(node)
    if a:node.path.isDirectory
        let self.root = a:node
    else
        call a:node.cacheParent()
        let self.root = a:node.parent
    endif

    call self.root.open()

    "change dir to the dir of the new root if instructed to
    if g:MDTreeChDirMode ==# 2
        call self.root.path.changeToDir()
    endif

    call self.render()
    call self.root.putCursorHere(0, 0)

    silent doautocmd User MDTreeNewRoot
endfunction

"FUNCTION: s:MDTree.Close() {{{1
"Closes the tab tree window for this tab
function! s:MDTree.Close()
    if !s:MDTree.IsOpen()
        return
    endif

    if winnr("$") != 1
        " Use the window ID to identify the currently active window or fall
        " back on the buffer ID if win_getid/win_gotoid are not available, in
        " which case we'll focus an arbitrary window showing the buffer.
        let l:useWinId = exists('*win_getid') && exists('*win_gotoid')

        if winnr() == s:MDTree.GetWinNum()
            call mdtree#exec("wincmd p")
            let l:activeBufOrWin = l:useWinId ? win_getid() : bufnr("")
            call mdtree#exec("wincmd p")
        else
            let l:activeBufOrWin = l:useWinId ? win_getid() : bufnr("")
        endif

        call mdtree#exec(s:MDTree.GetWinNum() . " wincmd w")
        close
        if l:useWinId
            call mdtree#exec("call win_gotoid(" . l:activeBufOrWin . ")")
        else
            call mdtree#exec(bufwinnr(l:activeBufOrWin) . " wincmd w")
        endif
    else
        close
    endif
endfunction

"FUNCTION: s:MDTree.CloseIfQuitOnOpen() {{{1
"Closes the NERD tree window if the close on open option is set
function! s:MDTree.CloseIfQuitOnOpen()
    if g:MDTreeQuitOnOpen && s:MDTree.IsOpen()
        call s:MDTree.Close()
    endif
endfunction

"FUNCTION: s:MDTree.CursorToBookmarkTable(){{{1
"Places the cursor at the top of the bookmarks table
function! s:MDTree.CursorToBookmarkTable()
    if !b:MDTree.ui.getShowBookmarks()
        throw "MDTree.IllegalOperationError: cant find bookmark table, bookmarks arent active"
    endif

    if g:MDTreeMinimalUI
        return cursor(1, 2)
    endif

    let rootNodeLine = b:MDTree.ui.getRootLineNum()

    let line = 1
    while getline(line) !~# '^>-\+Bookmarks-\+$'
        let line = line + 1
        if line >= rootNodeLine
            throw "MDTree.BookmarkTableNotFoundError: didnt find the bookmarks table"
        endif
    endwhile
    call cursor(line, 2)
endfunction

"FUNCTION: s:MDTree.CursorToTreeWin(){{{1
"Places the cursor in the nerd tree window
function! s:MDTree.CursorToTreeWin()
    call g:MDTree.MustBeOpen()
    call nerdtree#exec(g:MDTree.GetWinNum() . "wincmd w")
endfunction

" Function: s:MDTree.ExistsForBuffer()   {{{1
" Returns 1 if a nerd tree root exists in the current buffer
function! s:MDTree.ExistsForBuf()
    return exists("b:MDTree")
endfunction

" Function: s:MDTree.ExistsForTab()   {{{1
" Returns 1 if a nerd tree root exists in the current tab
function! s:MDTree.ExistsForTab()
    if !exists("t:MDTreeBufName")
        return
    end

    "check b:MDTree is still there and hasn't been e.g. :bdeleted
    return !empty(getbufvar(bufnr(t:MDTreeBufName), 'MDTree'))
endfunction

function! s:MDTree.ForCurrentBuf()
    if s:MDTree.ExistsForBuf()
        return b:MDTree
    else
        return {}
    endif
endfunction

"FUNCTION: s:MDTree.ForCurrentTab() {{{1
function! s:MDTree.ForCurrentTab()
    if !s:MDTree.ExistsForTab()
        return
    endif

    let bufnr = bufnr(t:MDTreeBufName)
    return getbufvar(bufnr, "MDTree")
endfunction

"FUNCTION: s:MDTree.getRoot() {{{1
function! s:MDTree.getRoot()
    return self.root
endfunction

"FUNCTION: s:MDTree.GetWinNum() {{{1
"gets the nerd tree window number for this tab
function! s:MDTree.GetWinNum()
    if exists("t:MDTreeBufName")
        return bufwinnr(t:MDTreeBufName)
    endif

    return -1
endfunction

"FUNCTION: s:MDTree.IsOpen() {{{1
function! s:MDTree.IsOpen()
    return s:MDTree.GetWinNum() != -1
endfunction

"FUNCTION: s:MDTree.isTabTree() {{{1
function! s:MDTree.isTabTree()
    return self._type == "tab"
endfunction

"FUNCTION: s:MDTree.isWinTree() {{{1
function! s:MDTree.isWinTree()
    return self._type == "window"
endfunction

"FUNCTION: s:MDTree.MustBeOpen() {{{1
function! s:MDTree.MustBeOpen()
    if !s:MDTree.IsOpen()
        throw "MDTree.TreeNotOpen"
    endif
endfunction

"FUNCTION: s:MDTree.New() {{{1
function! s:MDTree.New(path, type)
    let newObj = copy(self)
    let newObj.ui = g:MDTreeUI.New(newObj)
    let newObj.root = g:MDTreeRootNode.New(a:path, newObj)
    let newObj._type = a:type
    return newObj
endfunction

"FUNCTION: s:MDTree.PathFilters() {{{1
function! s:MDTree.PathFilters()
    if !exists('s:MDTree._PathFilters')
        let s:MDTree._PathFilters = []
    endif
    return s:MDTree._PathFilters
endfunction

"FUNCTION: s:MDTree.previousBuf() {{{1
function! s:MDTree.previousBuf()
    return self._previousBuf
endfunction

function! s:MDTree.setPreviousBuf(bnum)
    let self._previousBuf = a:bnum
endfunction

"FUNCTION: s:MDTree.render() {{{1
"A convenience function - since this is called often
function! s:MDTree.render()
    call self.ui.render()
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
