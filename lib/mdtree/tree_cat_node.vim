" ===================
" " CLASS: TreeCatNode
"
" The node for category
" ====================


let s:TreeCatNode = {}
let g:MDTreeCatNode = s:TreeCatNode

function! s:TreeCatNode.New(name, uuid, mdtree)
    let newTreeNode = copy(self)
    let newTreeNode.name = a:name
    let newTreeNode.uuid = a:uuid
    let newTreeNode.parent = {}
    let newTreeNode._mdtree = a:mdtree
    let newTreeNode.isOpen = 0
    let newTreeNode.children = []
    let newTreeNode.isCategory = 1
    return newTreeNode
endfunction

function! s:TreeCatNode.getVisibleChildren()
    return self.children
endfunction

function! s:TreeCatNode._initChildren(silent)
    let self.children = []
python << EOF
sub_cats =['g:MDTreeCatNode.New("%s", "%s", self._mdtree)' % c. for c in reader.sub_cat(vim.eval('self.uuid'))]
vim.command('let l:sub_cats = [%s]' % sub_cats)
EOF
    for i in l:sub_cats
        addChild(i)
    endfor
    return self.getChildCount()
endfunction

function! s:TreeCatNode.getChildCount()
    return len(self.children)
endfunction

function! s:TreeCatNode.addChild(node)
    call add(self.children, a:node)
    let a:node.parent = self
endfunction

function! s:TreeCatNode.open(...)
    let l:options = a:0 ? a:1 : {}
    let self.isOpen = 1

    let l:numChildrenCached = 0
    if empty(self.children)
        let l:numChildrenCached = self._initChildren(0)
    endif
    return l:numChildrenCached
endfunction

function! s:TreeCatNode.displayString()
    let l:result = ''
    
    let l:label = self.name

    if self.isOpen
        let l:symbol = g:MDTreeDirArrowCollapsible
    else 
        let l:symbol = g:MDTreeDirArrowExpandable
    endif

    let l:result = l:symbol . l:label . '|' . self.uuid
    return l:result
endfunction


function! s:TreeCatNode._renderToString(depth, drawText)
    let output = ""
    if a:drawText ==# 1
        let treeParts = repeat('  ', a:depth - 1)
        let line = treeParts . self.displayString()
        let output = output . line . "\n"
    endif

    if self.isOpen ==# 1
        let childNodesToDraw = self.children
        if len(childNodesToDraw) > 0
            for i in childNodesToDraw
                let output = output . i._renderToString(a:depth + 1, 1)
            endfor
        endif
    endif
    return output
endfunction

function! s:TreeCatNode.findNode(uuid)
    echo "Finding" . a:uuid
    if a:uuid == self.uuid
        return self
    endif
    if empty(self.children)
        return {}
    endif
    for i in self.children
        let retVal = i.findNode(a:uuid)
        if retVal != {}
            return retVal
        endif
    endfor
    return {}
endfunction
