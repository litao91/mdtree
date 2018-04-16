"CLASS: mdtree
"============================================================
let s:mdtree = {}
let g:mdtree = s:mdtree

"FUNCTION: s:mdtree.AddPathFilter() {{{1
function! s:mdtree.AddPathFilter(callback)
    call add(s:mdtree.PathFilters(), a:callback)
endfunction

"FUNCTION: s:mdtree.changeRoot(node) {{{1
function! s:mdtree.changeRoot(node)
    if a:node.path.isDirectory
        let self.root = a:node
    else
        call a:node.cacheParent()
        let self.root = a:node.parent
    endif

    call self.root.open()

    "change dir to the dir of the new root if instructed to
    if g:mdtreeChDirMode ==# 2
        call self.root.path.changeToDir()
    endif

    call self.render()
    call self.root.putCursorHere(0, 0)

    silent doautocmd User mdtreeNewRoot
endfunction

"FUNCTION: s:mdtree.Close() {{{1
"Closes the tab tree window for this tab
function! s:mdtree.Close()
    if !s:mdtree.IsOpen()
        return
    endif

    if winnr("$") != 1
        " Use the window ID to identify the currently active window or fall
        " back on the buffer ID if win_getid/win_gotoid are not available, in
        " which case we'll focus an arbitrary window showing the buffer.
        let l:useWinId = exists('*win_getid') && exists('*win_gotoid')

        if winnr() == s:mdtree.GetWinNum()
            call nerdtree#exec("wincmd p")
            let l:activeBufOrWin = l:useWinId ? win_getid() : bufnr("")
            call nerdtree#exec("wincmd p")
        else
            let l:activeBufOrWin = l:useWinId ? win_getid() : bufnr("")
        endif

        call nerdtree#exec(s:mdtree.GetWinNum() . " wincmd w")
        close
        if l:useWinId
            call nerdtree#exec("call win_gotoid(" . l:activeBufOrWin . ")")
        else
            call nerdtree#exec(bufwinnr(l:activeBufOrWin) . " wincmd w")
        endif
    else
        close
    endif
endfunction

"FUNCTION: s:mdtree.CloseIfQuitOnOpen() {{{1
"Closes the NERD tree window if the close on open option is set
function! s:mdtree.CloseIfQuitOnOpen()
    if g:mdtreeQuitOnOpen && s:mdtree.IsOpen()
        call s:mdtree.Close()
    endif
endfunction

"FUNCTION: s:mdtree.CursorToBookmarkTable(){{{1
"Places the cursor at the top of the bookmarks table
function! s:mdtree.CursorToBookmarkTable()
    if !b:mdtree.ui.getShowBookmarks()
        throw "mdtree.IllegalOperationError: cant find bookmark table, bookmarks arent active"
    endif

    if g:mdtreeMinimalUI
        return cursor(1, 2)
    endif

    let rootNodeLine = b:mdtree.ui.getRootLineNum()

    let line = 1
    while getline(line) !~# '^>-\+Bookmarks-\+$'
        let line = line + 1
        if line >= rootNodeLine
            throw "mdtree.BookmarkTableNotFoundError: didnt find the bookmarks table"
        endif
    endwhile
    call cursor(line, 2)
endfunction

"FUNCTION: s:mdtree.CursorToTreeWin(){{{1
"Places the cursor in the nerd tree window
function! s:mdtree.CursorToTreeWin()
    call g:mdtree.MustBeOpen()
    call nerdtree#exec(g:mdtree.GetWinNum() . "wincmd w")
endfunction

" Function: s:mdtree.ExistsForBuffer()   {{{1
" Returns 1 if a nerd tree root exists in the current buffer
function! s:mdtree.ExistsForBuf()
    return exists("b:mdtree")
endfunction

" Function: s:mdtree.ExistsForTab()   {{{1
" Returns 1 if a nerd tree root exists in the current tab
function! s:mdtree.ExistsForTab()
    if !exists("t:mdtreeBufName")
        return
    end

    "check b:mdtree is still there and hasn't been e.g. :bdeleted
    return !empty(getbufvar(bufnr(t:mdtreeBufName), 'mdtree'))
endfunction

function! s:mdtree.ForCurrentBuf()
    if s:mdtree.ExistsForBuf()
        return b:mdtree
    else
        return {}
    endif
endfunction

"FUNCTION: s:mdtree.ForCurrentTab() {{{1
function! s:mdtree.ForCurrentTab()
    if !s:mdtree.ExistsForTab()
        return
    endif

    let bufnr = bufnr(t:mdtreeBufName)
    return getbufvar(bufnr, "mdtree")
endfunction

"FUNCTION: s:mdtree.getRoot() {{{1
function! s:mdtree.getRoot()
    return self.root
endfunction

"FUNCTION: s:mdtree.GetWinNum() {{{1
"gets the nerd tree window number for this tab
function! s:mdtree.GetWinNum()
    if exists("t:mdtreeBufName")
        return bufwinnr(t:mdtreeBufName)
    endif

    return -1
endfunction

"FUNCTION: s:mdtree.IsOpen() {{{1
function! s:mdtree.IsOpen()
    return s:mdtree.GetWinNum() != -1
endfunction

"FUNCTION: s:mdtree.isTabTree() {{{1
function! s:mdtree.isTabTree()
    return self._type == "tab"
endfunction

"FUNCTION: s:mdtree.isWinTree() {{{1
function! s:mdtree.isWinTree()
    return self._type == "window"
endfunction

"FUNCTION: s:mdtree.MustBeOpen() {{{1
function! s:mdtree.MustBeOpen()
    if !s:mdtree.IsOpen()
        throw "mdtree.TreeNotOpen"
    endif
endfunction

"FUNCTION: s:mdtree.New() {{{1
function! s:mdtree.New(path, type)
    let newObj = copy(self)
    let newObj.ui = g:mdtreeUI.New(newObj)
    let newObj.root = g:mdtreeDirNode.New(a:path, newObj)
    let newObj._type = a:type
    return newObj
endfunction

"FUNCTION: s:mdtree.PathFilters() {{{1
function! s:mdtree.PathFilters()
    if !exists('s:mdtree._PathFilters')
        let s:mdtree._PathFilters = []
    endif
    return s:mdtree._PathFilters
endfunction

"FUNCTION: s:mdtree.previousBuf() {{{1
function! s:mdtree.previousBuf()
    return self._previousBuf
endfunction

function! s:mdtree.setPreviousBuf(bnum)
    let self._previousBuf = a:bnum
endfunction

"FUNCTION: s:mdtree.render() {{{1
"A convenience function - since this is called often
function! s:mdtree.render()
    call self.ui.render()
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
