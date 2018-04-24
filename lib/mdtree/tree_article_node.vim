let s:TreeArticleNode = {}
let g:MDTreeArticleNode = s:TreeArticleNode

function! s:TreeArticleNode.New(title, uuid, path, mdtree)
    let newArticleNode = copy(self)
    let newArticleNode.title = a:title
    let newArticleNode.uuid = a:uuid
    let newArticleNode.path = g:MDTreePath.New(a:path)
    let newArticleNode._mdtree = a:mdtree
    let newArticleNode.parent = {}
    let newArticleNode.isCategory = 0
    return newArticleNode
endfunction

function! s:TreeArticleNode._renderToString(depth, drawText)
    let output = ""
    if a:drawText ==# 1
        let treeParts = repeat('  ', a:depth - 1)
        let line = treeParts . self.displayString()
        let output = output . line . "\n"
    endif
    return output
endfunction

function! s:TreeArticleNode.displayString()
    return self.title . "|" . self.uuid
endfunction

function! s:TreeArticleNode.findNode(uuid)
    if self.uuid == a:uuid
        return self
    else
        return {}
    endif
endfunction

function! s:TreeArticleNode.activate(...)
    call self.open(a:0 ? a:1 : {})
endfunction

function! s:TreeArticleNode.open(...)
    let opts = a:0 ? a:1 : {}
    let opener = g:MDTreeOpener.New(self.path, opts)
    call opener.open(self)
endfunction

    
function! s:TreeArticleNode.delete()
python3 << EOF
import vim
import sys
import os
plugin_path = vim.eval('g:plugin_path')
python_module_path = os.path.abspath('%s/../python' % (plugin_path,))
sys.path.append(python_module_path)
reader = libreader.MainLib(vim.eval("self._mdtree.libname"))
uuid = vim.eval('self.uuid')
reader.del_article(uuid)
EOF
    call self.parent.removeChild(self)
endfunction
