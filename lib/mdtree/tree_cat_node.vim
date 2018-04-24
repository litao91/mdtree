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
python3 << EOF
import vim
import sys
import os
plugin_path = vim.eval('g:plugin_path')
python_module_path = os.path.abspath('%s/../python' % (plugin_path,))
sys.path.append(python_module_path)
reader = libreader.MainLib(vim.eval("self._mdtree.libname"))
sub_cats =['g:MDTreeCatNode.New("%s", "%s", self._mdtree)' % (c.name, c.uuid) for c in reader.sub_cat(vim.eval('self.uuid'))]
articles = ['g:MDTreeArticleNode.New("%s", "%s", "%s", self._mdtree)' % (a.title, str(a.uuid), a.path) for a in reader.articles(vim.eval('self.uuid')) if a.uuid is not None]
cmd = 'let l:sub_cats = [%s]' % ','.join(sub_cats + articles)
vim.command(cmd)
EOF
    if empty(l:sub_cats)
        return 0
    endif
    for i in l:sub_cats
        call self.addChild(i)
    endfor
    return self.getChildCount()
endfunction

function! s:TreeCatNode.getChildCount()
    return len(self.children)
endfunction

function! s:TreeCatNode.addChild(node)
    let a:node.parent = self
    call add(self.children, a:node)
endfunction

function! s:TreeCatNode.open()
    let self.isOpen = 1
    let l:numChildrenCached = 0
    if empty(self.children)
        let l:numChildrenCached = self._initChildren(0)
    endif
    return l:numChildrenCached
endfunction

function! s:TreeCatNode.close()
    let self.isOpen = 0
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
        for i in self.children
            let output = output . i._renderToString(a:depth + 1, 1)
        endfor
    endif
    return output
endfunction

function! s:TreeCatNode.findNode(uuid)
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

function! s:TreeCatNode.activate()
    call self.toggleOpen()
    call self._mdtree.render()
endfunction

function! s:TreeCatNode.delete()
    for i in self.children
        call i.delete()
    endfor
python3 << EOF
import vim
import sys
import os
plugin_path = vim.eval('g:plugin_path')
python_module_path = os.path.abspath('%s/../python' % (plugin_path,))
sys.path.append(python_module_path)
reader = libreader.MainLib(vim.eval("self._mdtree.libname"))
reader.del_cat(vim.eval("self.uuid"))
EOF
    call self.parent.removeChild(self)
endfunction

function! s:TreeCatNode.toggleOpen()
    if self.isOpen ==# 1
        call self.close()
    else
        call self.open()
    endif
endfunction

function! s:TreeCatNode.removeChild(treenode)
    for i in range(0, self.getChildCount() - 1)
        if self.children[i].uuid == a:treenode.uuid
            call remove(self.children, i)
            return
        endif
    endfor
endfunction
