" ============================================================================
" CLASS: TreeArticleNode
"
" This class is the parent of the "TreeDirNode" class and is the "Component"
" part of the composite design pattern between the MDTree node classes.
" ============================================================================


let s:TreeArticleNode = {}
let g:MDTreeArticleNode = s:TreeArticleNode

" FUNCTION: TreeArticleNode.activate(...) {{{1
function! s:TreeArticleNode.activate(...)
    call self.open(a:0 ? a:1 : {})
endfunction

" FUNCTION: TreeArticleNode.bookmark(name) {{{1
" bookmark this node with a:name
function! s:TreeArticleNode.bookmark(name)

    " if a bookmark exists with the same name and the node is cached then save
    " it so we can update its display string
    let oldMarkedNode = {}
    try
        let oldMarkedNode = g:MDTreeBookmark.GetNodeForName(a:name, 1, self.getmdtree())
    catch /^MDTree.BookmarkNotFoundError/
    catch /^MDTree.BookmarkedNodeNotFoundError/
    endtry

    call g:MDTreeBookmark.AddBookmark(a:name, self.path)
    call self.path.cacheDisplayString()
    call g:MDTreeBookmark.Write()

    if !empty(oldMarkedNode)
        call oldMarkedNode.path.cacheDisplayString()
    endif
endfunction

" FUNCTION: TreeArticleNode.cacheParent() {{{1
" initializes self.parent if it isnt already
function! s:TreeArticleNode.cacheParent()
    if empty(self.parent)
        let parentPath = self.path.getParent()
        if parentPath.equals(self.path)
            throw "MDTree.CannotCacheParentError: already at root"
        endif
        let self.parent = s:TreeArticleNode.New(parentPath, self.getmdtree())
    endif
endfunction

" FUNCTION: TreeArticleNode.clearBookmarks() {{{1
function! s:TreeArticleNode.clearBookmarks()
    for i in g:MDTreeBookmark.Bookmarks()
        if i.path.equals(self.path)
            call i.delete()
        end
    endfor
    call self.path.cacheDisplayString()
endfunction

" FUNCTION: TreeArticleNode.copy(dest) {{{1
function! s:TreeArticleNode.copy(dest)
    call self.path.copy(a:dest)
    let newPath = g:MDTreePath.New(a:dest)
    let parent = self.getmdtree().root.findNode(newPath.getParent())
    if !empty(parent)
        call parent.refresh()
        return parent.findNode(newPath)
    else
        return {}
    endif
endfunction

" FUNCTION: TreeArticleNode.delete {{{1
" Removes this node from the tree and calls the Delete method for its path obj
function! s:TreeArticleNode.delete()
    call self.path.delete()
    call self.parent.removeChild(self)
endfunction

" FUNCTION: TreeArticleNode.displayString() {{{1
"
" Returns a string that specifies how the node should be represented as a
" string
"
" Return:
" a string that can be used in the view to represent this node
function! s:TreeArticleNode.displayString()
    return self.path.flagSet.renderToString() . self.path.displayString()
endfunction

" FUNCTION: TreeArticleNode.equals(treenode) {{{1
"
" Compares this treenode to the input treenode and returns 1 if they are the
" same node.
"
" Use this method instead of ==  because sometimes when the treenodes contain
" many children, vim seg faults when doing ==
"
" Args:
" treenode: the other treenode to compare to
function! s:TreeArticleNode.equals(treenode)
    return self.path.str() ==# a:treenode.path.str()
endfunction

" FUNCTION: TreeArticleNode.findNode(path) {{{1
" Returns self if this node.path.Equals the given path.
" Returns {} if not equal.
"
" Args:
" path: the path object to compare against
function! s:TreeArticleNode.findNode(path)
    if a:path.equals(self.path)
        return self
    endif
    return {}
endfunction

" FUNCTION: TreeArticleNode.findOpenDirSiblingWithVisibleChildren(direction) {{{1
"
" Finds the next sibling for this node in the indicated direction. This sibling
" must be a directory and may/may not have children as specified.
"
" Args:
" direction: 0 if you want to find the previous sibling, 1 for the next sibling
"
" Return:
" a treenode object or {} if no appropriate sibling could be found
function! s:TreeArticleNode.findOpenDirSiblingWithVisibleChildren(direction)
    " if we have no parent then we can have no siblings
    if self.parent != {}
        let nextSibling = self.findSibling(a:direction)

        while nextSibling != {}
            if nextSibling.path.isDirectory && nextSibling.hasVisibleChildren() && nextSibling.isOpen
                return nextSibling
            endif
            let nextSibling = nextSibling.findSibling(a:direction)
        endwhile
    endif

    return {}
endfunction

" FUNCTION: TreeArticleNode.findSibling(direction) {{{1
"
" Finds the next sibling for this node in the indicated direction
"
" Args:
" direction: 0 if you want to find the previous sibling, 1 for the next sibling
"
" Return:
" a treenode object or {} if no sibling could be found
function! s:TreeArticleNode.findSibling(direction)
    " if we have no parent then we can have no siblings
    if self.parent != {}

        " get the index of this node in its parents children
        let siblingIndx = self.parent.getChildIndex(self.path)

        if siblingIndx != -1
            " move a long to the next potential sibling node
            let siblingIndx = a:direction ==# 1 ? siblingIndx+1 : siblingIndx-1

            " keep moving along to the next sibling till we find one that is valid
            let numSiblings = self.parent.getChildCount()
            while siblingIndx >= 0 && siblingIndx < numSiblings

                " if the next node is not an ignored node (i.e. wont show up in the
                " view) then return it
                if self.parent.children[siblingIndx].path.ignore(self.getmdtree()) ==# 0
                    return self.parent.children[siblingIndx]
                endif

                " go to next node
                let siblingIndx = a:direction ==# 1 ? siblingIndx+1 : siblingIndx-1
            endwhile
        endif
    endif

    return {}
endfunction

" FUNCTION: TreeArticleNode.getmdtree(){{{1
function! s:TreeArticleNode.getmdtree()
    return self._mdtree
endfunction

" FUNCTION: TreeArticleNode.GetRootForTab(){{{1
" get the root node for this tab
function! s:TreeArticleNode.GetRootForTab()
    if g:MDTree.ExistsForTab()
        return getbufvar(t:MDTreeBufName, 'MDTree').root
    end
    return {}
endfunction

" FUNCTION: TreeArticleNode.GetSelected() {{{1
" If the cursor is currently positioned on a tree node, return the node.
" Otherwise, return the empty dictionary.
function! s:TreeArticleNode.GetSelected()

    try
        let l:path = b:MDTree.ui.getPath(line('.'))

        if empty(l:path)
            return {}
        endif

        return b:MDTree.root.findNode(l:path)
    catch /^MDTree/
        return {}
    endtry
endfunction

" FUNCTION: TreeArticleNode.isVisible() {{{1
" returns 1 if this node should be visible according to the tree filters and
" hidden file filters (and their on/off status)
function! s:TreeArticleNode.isVisible()
    return !self.path.ignore(self.getmdtree())
endfunction

" FUNCTION: TreeArticleNode.isRoot() {{{1
function! s:TreeArticleNode.isRoot()
    if !g:MDTree.ExistsForBuf()
        throw "MDTree.NoTreeError: No tree exists for the current buffer"
    endif

    return self.equals(self.getmdtree().root)
endfunction

" FUNCTION: TreeArticleNode.New(path, mdtree) {{{1
" Returns a new TreeNode object with the given path and parent
"
" Args:
" path: file/dir that the node represents
" mdtree: the tree the node belongs to
function! s:TreeArticleNode.New(path, mdtree)
    if a:path.isDirectory
        return g:MDTreeCatNode.New(a:path, a:mdtree)
    else
        echo "ArticleNode"
    endif
endfunction

" FUNCTION: TreeArticleNode.open() {{{1
function! s:TreeArticleNode.open(...)
    let opts = a:0 ? a:1 : {}
    let opener = g:MDTreeOpener.New(self.path, opts)
    call opener.open(self)
endfunction

" FUNCTION: TreeArticleNode.openSplit() {{{1
" Open this node in a new window
function! s:TreeArticleNode.openSplit()
    call mdtree#deprecated('TreeArticleNode.openSplit', 'is deprecated, use .open() instead.')
    call self.open({'where': 'h'})
endfunction

" FUNCTION: TreeArticleNode.openVSplit() {{{1
" Open this node in a new vertical window
function! s:TreeArticleNode.openVSplit()
    call mdtree#deprecated('TreeArticleNode.openVSplit', 'is deprecated, use .open() instead.')
    call self.open({'where': 'v'})
endfunction

" FUNCTION: TreeArticleNode.openInNewTab(options) {{{1
function! s:TreeArticleNode.openInNewTab(options)
    echomsg 'TreeArticleNode.openInNewTab is deprecated'
    call self.open(extend({'where': 't'}, a:options))
endfunction

" FUNCTION: TreeArticleNode.putCursorHere(isJump, recurseUpward){{{1
" Places the cursor on the line number this node is rendered on
"
" Args:
" isJump: 1 if this cursor movement should be counted as a jump by vim
" recurseUpward: try to put the cursor on the parent if the this node isnt
" visible
function! s:TreeArticleNode.putCursorHere(isJump, recurseUpward)
    let ln = self.getmdtree().ui.getLineNum(self)
    if ln != -1
        if a:isJump
            mark '
        endif
        call cursor(ln, col("."))
    else
        if a:recurseUpward
            let node = self
            while node != {} && self.getmdtree().ui.getLineNum(node) ==# -1
                let node = node.parent
                call node.open()
            endwhile
            call self._mdtree.render()
            call node.putCursorHere(a:isJump, 0)
        endif
    endif
endfunction

" FUNCTION: TreeArticleNode.refresh() {{{1
function! s:TreeArticleNode.refresh()
    call self.path.refresh(self.getmdtree())
endfunction

" FUNCTION: TreeArticleNode.refreshFlags() {{{1
function! s:TreeArticleNode.refreshFlags()
    call self.path.refreshFlags(self.getmdtree())
endfunction

" FUNCTION: TreeArticleNode.rename() {{{1
" Calls the rename method for this nodes path obj
function! s:TreeArticleNode.rename(newName)
    let newName = substitute(a:newName, '\(\\\|\/\)$', '', '')
    call self.path.rename(newName)
    call self.parent.removeChild(self)

    let parentPath = self.path.getParent()
    let newParent = self.getmdtree().root.findNode(parentPath)

    if newParent != {}
        call newParent.createChild(self.path, 1)
        call newParent.refresh()
    endif
endfunction

" FUNCTION: TreeArticleNode.renderToString {{{1
" returns a string representation for this tree to be rendered in the view
function! s:TreeArticleNode.renderToString()
    return self._renderToString(0, 0)
endfunction

" Args:
" depth: the current depth in the tree for this call
" drawText: 1 if we should actually draw the line for this node (if 0 then the
" child nodes are rendered only)
" for each depth in the tree
function! s:TreeArticleNode._renderToString(depth, drawText)
    let output = ""
    if a:drawText ==# 1

        let treeParts = repeat('  ', a:depth - 1)

        if !self.path.isDirectory
            let treeParts = treeParts . '  '
        endif

        let line = treeParts . self.displayString()

        let output = output . line . "\n"
    endif

    " if the node is an open dir, draw its children
    if self.path.isDirectory ==# 1 && self.isOpen ==# 1

        let childNodesToDraw = self.getVisibleChildren()

        if self.isCascadable() && a:depth > 0

            let output = output . childNodesToDraw[0]._renderToString(a:depth, 0)

        elseif len(childNodesToDraw) > 0
            for i in childNodesToDraw
                let output = output . i._renderToString(a:depth + 1, 1)
            endfor
        endif
    endif

    return output
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
