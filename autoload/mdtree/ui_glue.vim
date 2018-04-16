if exists("g:loaded_nerdtree_ui_glue_autoload")
    finish
endif
let g:loaded_nerdtree_ui_glue_autoload = 1

" FUNCTION: nerdtree#ui_glue#createDefaultBindings() {{{1
function! nerdtree#ui_glue#createDefaultBindings()
    let s = '<SNR>' . s:SID() . '_'

    call MDTreeAddKeyMap({ 'key': '<MiddleMouse>', 'scope': 'all', 'callback': s . 'handleMiddleMouse' })
    call MDTreeAddKeyMap({ 'key': '<LeftRelease>', 'scope': "all", 'callback': s."handleLeftClick" })
    call MDTreeAddKeyMap({ 'key': '<2-LeftMouse>', 'scope': "DirNode", 'callback': s."activateDirNode" })
    call MDTreeAddKeyMap({ 'key': '<2-LeftMouse>', 'scope': "FileNode", 'callback': s."activateFileNode" })
    call MDTreeAddKeyMap({ 'key': '<2-LeftMouse>', 'scope': "Bookmark", 'callback': s."activateBookmark" })
    call MDTreeAddKeyMap({ 'key': '<2-LeftMouse>', 'scope': "all", 'callback': s."activateAll" })


    call MDTreeAddKeyMap({ 'key': g:MDTreeMapActivateNode, 'scope': "DirNode", 'callback': s."activateDirNode" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapActivateNode, 'scope': "FileNode", 'callback': s."activateFileNode" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapActivateNode, 'scope': "Bookmark", 'callback': s."activateBookmark" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapActivateNode, 'scope': "all", 'callback': s."activateAll" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapOpenSplit, 'scope': "Node", 'callback': s."openHSplit" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapOpenVSplit, 'scope': "Node", 'callback': s."openVSplit" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapOpenSplit, 'scope': "Bookmark", 'callback': s."openHSplit" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapOpenVSplit, 'scope': "Bookmark", 'callback': s."openVSplit" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapPreview, 'scope': "Node", 'callback': s."previewNodeCurrent" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapPreviewVSplit, 'scope': "Node", 'callback': s."previewNodeVSplit" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapPreviewSplit, 'scope': "Node", 'callback': s."previewNodeHSplit" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapPreview, 'scope': "Bookmark", 'callback': s."previewNodeCurrent" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapPreviewVSplit, 'scope': "Bookmark", 'callback': s."previewNodeVSplit" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapPreviewSplit, 'scope': "Bookmark", 'callback': s."previewNodeHSplit" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapOpenRecursively, 'scope': "DirNode", 'callback': s."openNodeRecursively" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapUpdir, 'scope': "all", 'callback': s."upDirCurrentRootClosed" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapUpdirKeepOpen, 'scope': "all", 'callback': s."upDirCurrentRootOpen" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapChangeRoot, 'scope': "Node", 'callback': s."chRoot" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapChdir, 'scope': "Node", 'callback': s."chCwd" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapQuit, 'scope': "all", 'callback': s."closeTreeWindow" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapCWD, 'scope': "all", 'callback': "nerdtree#ui_glue#chRootCwd" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapRefreshRoot, 'scope': "all", 'callback': s."refreshRoot" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapRefresh, 'scope': "Node", 'callback': s."refreshCurrent" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapHelp, 'scope': "all", 'callback': s."displayHelp" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapToggleZoom, 'scope': "all", 'callback': s."toggleZoom" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapToggleHidden, 'scope': "all", 'callback': s."toggleShowHidden" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapToggleFilters, 'scope': "all", 'callback': s."toggleIgnoreFilter" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapToggleFiles, 'scope': "all", 'callback': s."toggleShowFiles" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapToggleBookmarks, 'scope': "all", 'callback': s."toggleShowBookmarks" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapCloseDir, 'scope': "Node", 'callback': s."closeCurrentDir" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapCloseChildren, 'scope': "DirNode", 'callback': s."closeChildren" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapMenu, 'scope': "Node", 'callback': s."showMenu" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapJumpParent, 'scope': "Node", 'callback': s."jumpToParent" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapJumpFirstChild, 'scope': "Node", 'callback': s."jumpToFirstChild" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapJumpLastChild, 'scope': "Node", 'callback': s."jumpToLastChild" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapJumpRoot, 'scope': "all", 'callback': s."jumpToRoot" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapJumpNextSibling, 'scope': "Node", 'callback': s."jumpToNextSibling" })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapJumpPrevSibling, 'scope': "Node", 'callback': s."jumpToPrevSibling" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapOpenInTab, 'scope': 'Node', 'callback': s . 'openInNewTab' })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapOpenInTabSilent, 'scope': 'Node', 'callback': s . 'openInNewTabSilent' })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapOpenInTab, 'scope': 'Bookmark', 'callback': s . 'openInNewTab' })
    call MDTreeAddKeyMap({ 'key': g:MDTreeMapOpenInTabSilent, 'scope': 'Bookmark', 'callback': s . 'openInNewTabSilent' })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapOpenExpl, 'scope': "DirNode", 'callback': s."openExplorer" })

    call MDTreeAddKeyMap({ 'key': g:MDTreeMapDeleteBookmark, 'scope': "Bookmark", 'callback': s."deleteBookmark" })
endfunction


"SECTION: Interface bindings {{{1
"============================================================

"FUNCTION: s:activateAll() {{{1
"handle the user activating the updir line
function! s:activateAll()
    if getline(".") ==# g:MDTreeUI.UpDirLine()
        return nerdtree#ui_glue#upDir(0)
    endif
endfunction

" FUNCTION: s:activateDirNode(directoryNode) {{{1
function! s:activateDirNode(directoryNode)

    if a:directoryNode.isRoot() && a:directoryNode.isOpen
        call nerdtree#echo('cannot close tree root')
        return
    endif

    call a:directoryNode.activate()
endfunction

"FUNCTION: s:activateFileNode() {{{1
"handle the user activating a tree node
function! s:activateFileNode(node)
    call a:node.activate({'reuse': 'all', 'where': 'p'})
endfunction

"FUNCTION: s:activateBookmark() {{{1
"handle the user activating a bookmark
function! s:activateBookmark(bm)
    call a:bm.activate(b:MDTree, !a:bm.path.isDirectory ? {'where': 'p'} : {})
endfunction

" FUNCTION: nerdtree#ui_glue#bookmarkNode(name) {{{1
" Associate the current node with the given name
function! nerdtree#ui_glue#bookmarkNode(...)
    let currentNode = g:MDTreeFileNode.GetSelected()
    if currentNode != {}
        let name = a:1
        if empty(name)
            let name = currentNode.path.getLastPathComponent(0)
        endif
        try
            call currentNode.bookmark(name)
            call b:MDTree.render()
        catch /^MDTree.IllegalBookmarkNameError/
            call nerdtree#echo("bookmark names must not contain spaces")
        endtry
    else
        call nerdtree#echo("select a node first")
    endif
endfunction

" FUNCTION: s:chCwd(node) {{{1
function! s:chCwd(node)
    try
        call a:node.path.changeToDir()
    catch /^MDTree.PathChangeError/
        call nerdtree#echoWarning("could not change cwd")
    endtry
endfunction

" FUNCTION: s:chRoot(node) {{{1
" changes the current root to the selected one
function! s:chRoot(node)
    call b:MDTree.changeRoot(a:node)
endfunction

" FUNCTION: s:nerdtree#ui_glue#chRootCwd() {{{1
" changes the current root to CWD
function! nerdtree#ui_glue#chRootCwd()
    try
        let cwd = g:MDTreePath.New(getcwd())
    catch /^MDTree.InvalidArgumentsError/
        call nerdtree#echo("current directory does not exist.")
        return
    endtry
    if cwd.str() == g:MDTreeFileNode.GetRootForTab().path.str()
       return
    endif
    call s:chRoot(g:MDTreeDirNode.New(cwd, b:MDTree))
endfunction

" FUNCTION: nnerdtree#ui_glue#clearBookmarks(bookmarks) {{{1
function! nerdtree#ui_glue#clearBookmarks(bookmarks)
    if a:bookmarks ==# ''
        let currentNode = g:MDTreeFileNode.GetSelected()
        if currentNode != {}
            call currentNode.clearBookmarks()
        endif
    else
        for name in split(a:bookmarks, ' ')
            let bookmark = g:MDTreeBookmark.BookmarkFor(name)
            call bookmark.delete()
        endfor
    endif
    call b:MDTree.root.refresh()
    call b:MDTree.render()
endfunction

" FUNCTION: s:closeChildren(node) {{{1
" closes all childnodes of the current node
function! s:closeChildren(node)
    call a:node.closeChildren()
    call b:MDTree.render()
    call a:node.putCursorHere(0, 0)
endfunction

" FUNCTION: s:closeCurrentDir(node) {{{1
" Close the parent directory of the current node.
function! s:closeCurrentDir(node)

    if a:node.isRoot()
        call nerdtree#echo('cannot close parent of tree root')
        return
    endif

    let l:parent = a:node.parent

    while l:parent.isCascadable()
        let l:parent = l:parent.parent
    endwhile

    if l:parent.isRoot()
        call nerdtree#echo('cannot close tree root')
        return
    endif

    call l:parent.close()
    call b:MDTree.render()
    call l:parent.putCursorHere(0, 0)
endfunction

" FUNCTION: s:closeTreeWindow() {{{1
" close the tree window
function! s:closeTreeWindow()
    if b:MDTree.isWinTree() && b:MDTree.previousBuf() != -1
        exec "buffer " . b:MDTree.previousBuf()
    else
        if winnr("$") > 1
            call g:MDTree.Close()
        else
            call nerdtree#echo("Cannot close last window")
        endif
    endif
endfunction

" FUNCTION: s:deleteBookmark(bookmark) {{{1
" Prompt the user to confirm the deletion of the selected bookmark.
function! s:deleteBookmark(bookmark)
    let l:message = "Delete the bookmark \"" . a:bookmark.name
                \ . "\" from the bookmark list?"

    let l:choices = "&Yes\n&No"

    echo | redraw
    let l:selection = confirm(l:message, l:choices, 1, 'Warning')

    if l:selection != 1
        call nerdtree#echo('bookmark not deleted')
        return
    endif

    try
        call a:bookmark.delete()
        silent call b:MDTree.root.refresh()
        call b:MDTree.render()
        echo | redraw
    catch /^MDTree/
        call nerdtree#echoWarning('could not remove bookmark')
    endtry
endfunction

" FUNCTION: s:displayHelp() {{{1
" toggles the help display
function! s:displayHelp()
    call b:MDTree.ui.toggleHelp()
    call b:MDTree.render()
    call b:MDTree.ui.centerView()
endfunction

" FUNCTION: s:findAndRevealPath(pathStr) {{{1
function! s:findAndRevealPath(pathStr)
    let l:pathStr = !empty(a:pathStr) ? a:pathStr : expand('%:p')

    if empty(l:pathStr)
        call nerdtree#echoWarning('no file for the current buffer')
        return
    endif

    try
        let l:pathObj = g:MDTreePath.New(l:pathStr)
    catch /^MDTree.InvalidArgumentsError/
        call nerdtree#echoWarning('invalid path')
        return
    endtry

    if !g:MDTree.ExistsForTab()
        try
            let l:cwd = g:MDTreePath.New(getcwd())
        catch /^MDTree.InvalidArgumentsError/
            call nerdtree#echo('current directory does not exist.')
            let l:cwd = l:pathObj.getParent()
        endtry

        if l:pathObj.isUnder(l:cwd)
            call g:MDTreeCreator.CreateTabTree(l:cwd.str())
        else
            call g:MDTreeCreator.CreateTabTree(l:pathObj.getParent().str())
        endif
    else
        MDTreeFocus

        if !l:pathObj.isUnder(b:MDTree.root.path)
            call s:chRoot(g:MDTreeDirNode.New(l:pathObj.getParent(), b:MDTree))
        endif
    endif

    if l:pathObj.isHiddenUnder(b:MDTree.root.path)
        call b:MDTree.ui.setShowHidden(1)
    endif

    let l:node = b:MDTree.root.reveal(l:pathObj)
    call b:MDTree.render()
    call l:node.putCursorHere(1, 0)
endfunction

"FUNCTION: s:handleLeftClick() {{{1
"Checks if the click should open the current node
function! s:handleLeftClick()
    let currentNode = g:MDTreeFileNode.GetSelected()
    if currentNode != {}

        "the dir arrows are multibyte chars, and vim's string functions only
        "deal with single bytes - so split the line up with the hack below and
        "take the line substring manually
        let line = split(getline(line(".")), '\zs')
        let startToCur = ""
        for i in range(0,len(line)-1)
            let startToCur .= line[i]
        endfor

        if currentNode.path.isDirectory
            if startToCur =~# g:MDTreeUI.MarkupReg() && startToCur =~# '[+~'.g:MDTreeDirArrowExpandable.g:MDTreeDirArrowCollapsible.'] \?$'
                call currentNode.activate()
                return
            endif
        endif

        if (g:MDTreeMouseMode ==# 2 && currentNode.path.isDirectory) || g:MDTreeMouseMode ==# 3
            let char = strpart(startToCur, strlen(startToCur)-1, 1)
            if char !~# g:MDTreeUI.MarkupReg()
                if currentNode.path.isDirectory
                    call currentNode.activate()
                else
                    call currentNode.activate({'reuse': 'all', 'where': 'p'})
                endif
                return
            endif
        endif
    endif
endfunction

" FUNCTION: s:handleMiddleMouse() {{{1
function! s:handleMiddleMouse()

    " A middle mouse click does not automatically position the cursor as one
    " would expect. Forcing the execution of a regular left mouse click here
    " fixes this problem.
    execute "normal! \<LeftMouse>"

    let l:currentNode = g:MDTreeFileNode.GetSelected()
    if empty(l:currentNode)
        call nerdtree#echoError('use the pointer to select a node')
        return
    endif

    if l:currentNode.path.isDirectory
        call l:currentNode.openExplorer()
    else
        call l:currentNode.open({'where': 'h'})
    endif
endfunction

" FUNCTION: s:jumpToChild(direction) {{{2
" Args:
" direction: 0 if going to first child, 1 if going to last
function! s:jumpToChild(currentNode, direction)
    if a:currentNode.isRoot()
        return nerdtree#echo("cannot jump to " . (a:direction ? "last" : "first") .  " child")
    end
    let dirNode = a:currentNode.parent
    let childNodes = dirNode.getVisibleChildren()

    let targetNode = childNodes[0]
    if a:direction
        let targetNode = childNodes[len(childNodes) - 1]
    endif

    if targetNode.equals(a:currentNode)
        let siblingDir = a:currentNode.parent.findOpenDirSiblingWithVisibleChildren(a:direction)
        if siblingDir != {}
            let indx = a:direction ? siblingDir.getVisibleChildCount()-1 : 0
            let targetNode = siblingDir.getChildByIndex(indx, 1)
        endif
    endif

    call targetNode.putCursorHere(1, 0)

    call b:MDTree.ui.centerView()
endfunction


" FUNCTION: nerdtree#ui_glue#invokeKeyMap(key) {{{1
"this is needed since I cant figure out how to invoke dict functions from a
"key map
function! nerdtree#ui_glue#invokeKeyMap(key)
    call g:MDTreeKeyMap.Invoke(a:key)
endfunction

" FUNCTION: s:jumpToFirstChild() {{{1
" wrapper for the jump to child method
function! s:jumpToFirstChild(node)
    call s:jumpToChild(a:node, 0)
endfunction

" FUNCTION: s:jumpToLastChild() {{{1
" wrapper for the jump to child method
function! s:jumpToLastChild(node)
    call s:jumpToChild(a:node, 1)
endfunction

" FUNCTION: s:jumpToParent(node) {{{1
" Move the cursor to the parent of the specified node. For a cascade, move to
" the parent of the cascade's highest node. At the root, do nothing.
function! s:jumpToParent(node)
    let l:parent = a:node.parent

    " If "a:node" represents a directory, back out of its cascade.
    if a:node.path.isDirectory
        while !empty(l:parent) && !l:parent.isRoot()
            if index(l:parent.getCascade(), a:node) >= 0
                let l:parent = l:parent.parent
            else
                break
            endif
        endwhile
    endif

    if !empty(l:parent)
        call l:parent.putCursorHere(1, 0)
        call b:MDTree.ui.centerView()
    else
        call nerdtree#echo('could not jump to parent node')
    endif
endfunction

" FUNCTION: s:jumpToRoot() {{{1
" moves the cursor to the root node
function! s:jumpToRoot()
    call b:MDTree.root.putCursorHere(1, 0)
    call b:MDTree.ui.centerView()
endfunction

" FUNCTION: s:jumpToNextSibling(node) {{{1
function! s:jumpToNextSibling(node)
    call s:jumpToSibling(a:node, 1)
endfunction

" FUNCTION: s:jumpToPrevSibling(node) {{{1
function! s:jumpToPrevSibling(node)
    call s:jumpToSibling(a:node, 0)
endfunction

" FUNCTION: s:jumpToSibling(currentNode, forward) {{{2
" moves the cursor to the sibling of the current node in the given direction
"
" Args:
" forward: 1 if the cursor should move to the next sibling, 0 if it should
" move back to the previous sibling
function! s:jumpToSibling(currentNode, forward)
    let sibling = a:currentNode.findSibling(a:forward)

    if !empty(sibling)
        call sibling.putCursorHere(1, 0)
        call b:MDTree.ui.centerView()
    endif
endfunction

" FUNCTION: nerdtree#ui_glue#openBookmark(name) {{{1
" Open the Bookmark that has the specified name. This function provides the
" implementation for the ":OpenBookmark" command.
function! nerdtree#ui_glue#openBookmark(name)
    try
        let l:bookmark = g:MDTreeBookmark.BookmarkFor(a:name)
    catch /^MDTree.BookmarkNotFoundError/
        call nerdtree#echoError('bookmark "' . a:name . '" not found')
        return
    endtry
    if l:bookmark.path.isDirectory
        call l:bookmark.open(b:MDTree)
    else
        call l:bookmark.open(b:MDTree, {'where': 'p'})
    endif
endfunction

" FUNCTION: s:openHSplit(target) {{{1
function! s:openHSplit(target)
    call a:target.activate({'where': 'h'})
endfunction

" FUNCTION: s:openVSplit(target) {{{1
function! s:openVSplit(target)
    call a:target.activate({'where': 'v'})
endfunction

" FUNCTION: s:openExplorer(node) {{{1
function! s:openExplorer(node)
    call a:node.openExplorer()
endfunction

" FUNCTION: s:openInNewTab(target) {{{1
function! s:openInNewTab(target)
    let l:opener = g:MDTreeOpener.New(a:target.path, {'where': 't'})
    call l:opener.open(a:target)
endfunction

" FUNCTION: s:openInNewTabSilent(target) {{{1
function! s:openInNewTabSilent(target)
    let l:opener = g:MDTreeOpener.New(a:target.path, {'where': 't', 'stay': 1})
    call l:opener.open(a:target)
endfunction

" FUNCTION: s:openNodeRecursively(node) {{{1
function! s:openNodeRecursively(node)
    call nerdtree#echo("Recursively opening node. Please wait...")
    call a:node.openRecursively()
    call b:MDTree.render()
    redraw
    call nerdtree#echo("Recursively opening node. Please wait... DONE")
endfunction

"FUNCTION: s:previewNodeCurrent(node) {{{1
function! s:previewNodeCurrent(node)
    call a:node.open({'stay': 1, 'where': 'p', 'keepopen': 1})
endfunction

"FUNCTION: s:previewNodeHSplit(node) {{{1
function! s:previewNodeHSplit(node)
    call a:node.open({'stay': 1, 'where': 'h', 'keepopen': 1})
endfunction

"FUNCTION: s:previewNodeVSplit(node) {{{1
function! s:previewNodeVSplit(node)
    call a:node.open({'stay': 1, 'where': 'v', 'keepopen': 1})
endfunction

" FUNCTION: nerdtree#ui_glue#revealBookmark(name) {{{1
" put the cursor on the node associate with the given name
function! nerdtree#ui_glue#revealBookmark(name)
    try
        let targetNode = g:MDTreeBookmark.GetNodeForName(a:name, 0, b:MDTree)
        call targetNode.putCursorHere(0, 1)
    catch /^MDTree.BookmarkNotFoundError/
        call nerdtree#echo("Bookmark isnt cached under the current root")
    endtry
endfunction

" FUNCTION: s:refreshRoot() {{{1
" Reloads the current root. All nodes below this will be lost and the root dir
" will be reloaded.
function! s:refreshRoot()
    call nerdtree#echo("Refreshing the root node. This could take a while...")
    call b:MDTree.root.refresh()
    call b:MDTree.render()
    redraw
    call nerdtree#echo("Refreshing the root node. This could take a while... DONE")
endfunction

" FUNCTION: s:refreshCurrent(node) {{{1
" refreshes the root for the current node
function! s:refreshCurrent(node)
    let node = a:node
    if !node.path.isDirectory
        let node = node.parent
    endif

    call nerdtree#echo("Refreshing node. This could take a while...")
    call node.refresh()
    call b:MDTree.render()
    redraw
    call nerdtree#echo("Refreshing node. This could take a while... DONE")
endfunction

" FUNCTION: nerdtree#ui_glue#setupCommands() {{{1
function! nerdtree#ui_glue#setupCommands()
    command! -n=? -complete=dir -bar MDTree :call g:MDTreeCreator.CreateTabTree('<args>')
    command! -n=? -complete=dir -bar MDTreeToggle :call g:MDTreeCreator.ToggleTabTree('<args>')
    command! -n=0 -bar MDTreeClose :call g:MDTree.Close()
    command! -n=1 -complete=customlist,nerdtree#completeBookmarks -bar MDTreeFromBookmark call g:MDTreeCreator.CreateTabTree('<args>')
    command! -n=0 -bar MDTreeMirror call g:MDTreeCreator.CreateMirror()
    command! -n=? -complete=file -bar MDTreeFind call s:findAndRevealPath('<args>')
    command! -n=0 -bar MDTreeFocus call MDTreeFocus()
    command! -n=0 -bar MDTreeCWD call MDTreeCWD()
endfunction

" Function: s:SID()   {{{1
function s:SID()
    if !exists("s:sid")
        let s:sid = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
    endif
    return s:sid
endfun

" FUNCTION: s:showMenu(node) {{{1
function! s:showMenu(node)
    let mc = g:MDTreeMenuController.New(g:MDTreeMenuItem.AllEnabled())
    call mc.showMenu()
endfunction

" FUNCTION: s:toggleIgnoreFilter() {{{1
function! s:toggleIgnoreFilter()
    call b:MDTree.ui.toggleIgnoreFilter()
endfunction

" FUNCTION: s:toggleShowBookmarks() {{{1
function! s:toggleShowBookmarks()
    call b:MDTree.ui.toggleShowBookmarks()
endfunction

" FUNCTION: s:toggleShowFiles() {{{1
function! s:toggleShowFiles()
    call b:MDTree.ui.toggleShowFiles()
endfunction

" FUNCTION: s:toggleShowHidden() {{{1
" toggles the display of hidden files
function! s:toggleShowHidden()
    call b:MDTree.ui.toggleShowHidden()
endfunction

" FUNCTION: s:toggleZoom() {{{1
function! s:toggleZoom()
    call b:MDTree.ui.toggleZoom()
endfunction

"FUNCTION: nerdtree#ui_glue#upDir(keepState) {{{1
"moves the tree up a level
"
"Args:
"keepState: 1 if the current root should be left open when the tree is
"re-rendered
function! nerdtree#ui_glue#upDir(keepState)
    let cwd = b:MDTree.root.path.str({'format': 'UI'})
    if cwd ==# "/" || cwd =~# '^[^/]..$'
        call nerdtree#echo("already at top dir")
    else
        if !a:keepState
            call b:MDTree.root.close()
        endif

        let oldRoot = b:MDTree.root

        if empty(b:MDTree.root.parent)
            let path = b:MDTree.root.path.getParent()
            let newRoot = g:MDTreeDirNode.New(path, b:MDTree)
            call newRoot.open()
            call newRoot.transplantChild(b:MDTree.root)
            let b:MDTree.root = newRoot
        else
            let b:MDTree.root = b:MDTree.root.parent
        endif

        if g:MDTreeChDirMode ==# 2
            call b:MDTree.root.path.changeToDir()
        endif

        call b:MDTree.render()
        call oldRoot.putCursorHere(0, 0)
    endif
endfunction

" FUNCTION: s:upDirCurrentRootOpen() {{{1
function! s:upDirCurrentRootOpen()
    call nerdtree#ui_glue#upDir(1)
endfunction

" FUNCTION: s:upDirCurrentRootClosed() {{{1
function! s:upDirCurrentRootClosed()
    call nerdtree#ui_glue#upDir(0)
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
