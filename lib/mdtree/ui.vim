" ============================================================================
" CLASS: UI
" ============================================================================


let s:UI = {}
let g:MDTreeUI = s:UI

" FUNCTION: s:UI.centerView() {{{2
" centers the nerd tree window around the cursor (provided the nerd tree
" options permit)
function! s:UI.centerView()
    if g:mdtreeAutoCenter
        let current_line = winline()
        let lines_to_top = current_line
        let lines_to_bottom = winheight(g:mdtree.GetWinNum()) - current_line
        if lines_to_top < g:mdtreeAutoCenterThreshold || lines_to_bottom < g:mdtreeAutoCenterThreshold
            normal! zz
        endif
    endif
endfunction


" FUNCTION: s:UI.new(mdtree) {{{1
function! s:UI.New(mdtree)
    let newObj = copy(self)
    let newObj.mdtree = a:mdtree
    return newObj
endfunction

" FUNCTION: s:UI.getPath(ln) {{{1
" Return the "Path" object for the node that is rendered on the given line
" number.  If the "up a dir" line is selected, return the "Path" object for
" the parent of the root.  Return the empty dictionary if the given line
" does not reference a tree node.
function! s:UI.getPath(ln)
    let line = getline(a:ln)

    let rootLine = self.getRootLineNum()

    if a:ln == rootLine
        return self.mdtree.root.path
    endif

    if line ==# s:UI.UpDirLine()
        return self.mdtree.root.path.getParent()
    endif

    if a:ln < rootLine
        return {}
    endif

    let indent = self._indentLevelFor(line)

    " remove the tree parts and the leading space
    let curFile = self._stripMarkup(line)

    let dir = ""
    let lnum = a:ln
    while lnum > 0
        let lnum = lnum - 1
        let curLine = getline(lnum)
        let curLineStripped = self._stripMarkup(curLine)

        " have we reached the top of the tree?
        if lnum == rootLine
            let dir = self.mdtree.root.path.str({'format': 'UI'}) . dir
            break
        endif
        if curLineStripped =~# '/$'
            let lpindent = self._indentLevelFor(curLine)
            if lpindent < indent
                let indent = indent - 1

                let dir = substitute (curLineStripped,'^\\', "", "") . dir
                continue
            endif
        endif
    endwhile
    let curFile = self.mdtree.root.path.drive . dir . curFile
    let toReturn = g:mdtreePath.New(curFile)
    return toReturn
endfunction

" FUNCTION: s:UI.getLineNum(file_node){{{1
" returns the line number this node is rendered on, or -1 if it isnt rendered
function! s:UI.getLineNum(file_node)
    " if the node is the root then return the root line no.
    if a:file_node.isRoot()
        return self.getRootLineNum()
    endif

    let totalLines = line("$")

    " the path components we have matched so far
    let pathcomponents = [substitute(self.mdtree.root.path.str({'format': 'UI'}), '/ *$', '', '')]
    " the index of the component we are searching for
    let curPathComponent = 1

    let fullpath = a:file_node.path.str({'format': 'UI'})

    let lnum = self.getRootLineNum()
    while lnum > 0
        let lnum = lnum + 1
        " have we reached the bottom of the tree?
        if lnum ==# totalLines+1
            return -1
        endif

        let curLine = getline(lnum)

        let indent = self._indentLevelFor(curLine)
        if indent ==# curPathComponent
            let curLine = self._stripMarkup(curLine)

            let curPath =  join(pathcomponents, '/') . '/' . curLine
            if stridx(fullpath, curPath, 0) ==# 0
                if fullpath ==# curPath || strpart(fullpath, len(curPath)-1,1) ==# '/'
                    let curLine = substitute(curLine, '/ *$', '', '')
                    call add(pathcomponents, curLine)
                    let curPathComponent = curPathComponent + 1

                    if fullpath ==# curPath
                        return lnum
                    endif
                endif
            endif
        endif
    endwhile
    return -1
endfunction

" FUNCTION: s:UI.getRootLineNum(){{{1
" gets the line number of the root node
function! s:UI.getRootLineNum()
    let rootLine = 1
    while getline(rootLine) !~# '^\(/\|<\)'
        let rootLine = rootLine + 1
    endwhile
    return rootLine
endfunction

" FUNCTION: s:UI.getShowBookmarks() {{{1
function! s:UI.getShowBookmarks()
    return self._showBookmarks
endfunction

" FUNCTION: s:UI.getShowFiles() {{{1
function! s:UI.getShowFiles()
    return self._showFiles
endfunction

" FUNCTION: s:UI.getShowHelp() {{{1
function! s:UI.getShowHelp()
    return self._showHelp
endfunction

" FUNCTION: s:UI.getShowHidden() {{{1
function! s:UI.getShowHidden()
    return self._showHidden
endfunction

" FUNCTION: s:UI._indentLevelFor(line) {{{1
function! s:UI._indentLevelFor(line)
    " have to do this work around because match() returns bytes, not chars
    let numLeadBytes = match(a:line, '\M\[^ '.g:mdtreeDirArrowExpandable.g:mdtreeDirArrowCollapsible.']')
    " The next line is a backward-compatible workaround for strchars(a:line(0:numLeadBytes-1]). strchars() is in 7.3+
    let leadChars = len(split(a:line[0:numLeadBytes-1], '\zs'))

    return leadChars / s:UI.IndentWid()
endfunction

" FUNCTION: s:UI.IndentWid() {{{1
function! s:UI.IndentWid()
    return 2
endfunction

" FUNCTION: s:UI.isIgnoreFilterEnabled() {{{1
function! s:UI.isIgnoreFilterEnabled()
    return self._ignoreEnabled == 1
endfunction

" FUNCTION: s:UI.isMinimal() {{{1
function! s:UI.isMinimal()
    return g:mdtreeMinimalUI
endfunction

" FUNCTION: s:UI.MarkupReg() {{{1
function! s:UI.MarkupReg()
    return '^\(['.g:mdtreeDirArrowExpandable.g:mdtreeDirArrowCollapsible.'] \| \+['.g:mdtreeDirArrowExpandable.g:mdtreeDirArrowCollapsible.'] \| \+\)'
endfunction

" FUNCTION: s:UI._renderBookmarks {{{1
function! s:UI._renderBookmarks()

    if !self.isMinimal()
        call setline(line(".")+1, ">----------Bookmarks----------")
        call cursor(line(".")+1, col("."))
    endif

    if g:mdtreeBookmarksSort == 1 || g:mdtreeBookmarksSort == 2
        call g:mdtreeBookmark.SortBookmarksList()
    endif

    for i in g:mdtreeBookmark.Bookmarks()
        call setline(line(".")+1, i.str())
        call cursor(line(".")+1, col("."))
    endfor

    call setline(line(".")+1, '')
    call cursor(line(".")+1, col("."))
endfunction

" FUNCTION: s:UI.restoreScreenState() {{{1
"
" Sets the screen state back to what it was when mdtree#saveScreenState was last
" called.
"
" Assumes the cursor is in the mdtree window
function! s:UI.restoreScreenState()
    if !has_key(self, '_screenState')
        return
    endif
    exec("silent vertical resize " . self._screenState['oldWindowSize'])

    let old_scrolloff=&scrolloff
    let &scrolloff=0
    call cursor(self._screenState['oldTopLine'], 0)
    normal! zt
    call setpos(".", self._screenState['oldPos'])
    let &scrolloff=old_scrolloff
endfunction

" FUNCTION: s:UI.saveScreenState() {{{1
" Saves the current cursor position in the current buffer and the window
" scroll position
function! s:UI.saveScreenState()
    let win = winnr()
    call g:mdtree.CursorToTreeWin()
    let self._screenState = {}
    let self._screenState['oldPos'] = getpos(".")
    let self._screenState['oldTopLine'] = line("w0")
    let self._screenState['oldWindowSize']= winwidth("")
    call mdtree#exec(win . "wincmd w")
endfunction

" FUNCTION: s:UI.setShowHidden(val) {{{1
function! s:UI.setShowHidden(val)
    let self._showHidden = a:val
endfunction

" FUNCTION: s:UI._stripMarkup(line){{{1
" returns the given line with all the tree parts stripped off
"
" Args:
" line: the subject line
function! s:UI._stripMarkup(line)
    let line = a:line
    " remove the tree parts and the leading space
    let line = substitute (line, g:MDTreeUI.MarkupReg(),"","")

    " strip off any read only flag
    let line = substitute (line, ' \['.g:mdtreeGlyphReadOnly.'\]', "","")

    " strip off any bookmark flags
    let line = substitute (line, ' {[^}]*}', "","")

    " strip off any executable flags
    let line = substitute (line, '*\ze\($\| \)', "","")

    " strip off any generic flags
    let line = substitute (line, '\[[^]]*\]', "","")

    let line = substitute (line,' -> .*',"","") " remove link to

    return line
endfunction

" FUNCTION: s:UI.render() {{{1
function! s:UI.render()
    setlocal modifiable

    " remember the top line of the buffer and the current line so we can
    " restore the view exactly how it was
    let curLine = line(".")
    let curCol = col(".")
    let topLine = line("w0")

    " delete all lines in the buffer (being careful not to clobber a register)
    silent 1,$delete _

    " draw the header line
    let header = self.mdtree.root.path.pathStr
    call setline(line(".")+1, header)
    call cursor(line(".")+1, col("."))

    " draw the tree
    silent put =self.mdtree.root.renderToString()

    " delete the blank line at the top of the buffer
    silent 1,1delete _

    " restore the view
    let old_scrolloff=&scrolloff
    let &scrolloff=0
    call cursor(topLine, 1)
    normal! zt
    call cursor(curLine, curCol)
    let &scrolloff = old_scrolloff

    setlocal nomodifiable
endfunction


" FUNCTION: UI.renderViewSavingPosition {{{1
" Renders the tree and ensures the cursor stays on the current node or the
" current nodes parent if it is no longer available upon re-rendering
function! s:UI.renderViewSavingPosition()
    let currentNode = g:MDTreeRootNode.GetSelected()

    " go up the tree till we find a node that will be visible or till we run
    " out of nodes
    while currentNode != {} && !currentNode.isVisible() && !currentNode.isRoot()
        let currentNode = currentNode.parent
    endwhile

    call self.render()

    if currentNode != {}
        call currentNode.putCursorHere(0, 0)
    endif
endfunction

" FUNCTION: s:UI.toggleHelp() {{{1
function! s:UI.toggleHelp()
    let self._showHelp = !self._showHelp
endfunction


" FUNCTION: s:UI.toggleShowFiles() {{{1
" toggles the display of hidden files
function! s:UI.toggleShowFiles()
    let self._showFiles = !self._showFiles
    call self.renderViewSavingPosition()
    call self.centerView()
endfunction


" FUNCTION: s:UI.toggleZoom() {{{1
" zoom (maximize/minimize) the mdtree window
function! s:UI.toggleZoom()
    if exists("b:mdtreeZoomed") && b:mdtreeZoomed
        let size = exists("b:mdtreeOldWindowSize") ? b:mdtreeOldWindowSize : g:mdtreeWinSize
        exec "silent vertical resize ". size
        let b:mdtreeZoomed = 0
    else
        exec "vertical resize"
        let b:mdtreeZoomed = 1
    endif
endfunction

" FUNCTION: s:UI.UpDirLine() {{{1
function! s:UI.UpDirLine()
    return '.. (up a dir)'
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
