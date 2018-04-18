let s:TreeRootNode = {}
let g:MDTreeRootNode = s:TreeRootNode

function! s:TreeRootNode.New(path, mdtree)
    if a:path.isDirectory != 1
        throw "mdtree.InvalidArgumentsError: A TreeRoot object must be instantiated with a directory path object. "
    endif

    let newRootNode = copy(self)
    let newRootNode.path = a:path
    let newRootNode.isOpen = 0
    let newRootNode.children = []
    let newRootNode._mdtree = a:mdtree
    let newRootNode.libname = newRootNode.path.pathStr . "/" . g:MDTreeLibName
    return newRootNode
endfunction


" FUNCTION: TreeRootNode.open([options]) {{{1
" Open this root node in the current tree or elsewhere if special options
" are provided. Return 0 if options were processed. Otherwise, return the
" number of new cached nodes.
function! s:TreeRootNode.open()
    let self.isOpen = 1
    let l:numChildrenCached = 0
    if empty(self.children)
        let l:numChildrenCached = self._initChildren(0)
    endif
    return l:numChildrenCached
endfunction

function! s:TreeRootNode.getChildCount()
    return len(self.children)
endfunction


function! s:TreeRootNode._initChildren(silent)
    let self.children = []
python3 << EOF
from mweb import libreader
reader = libreader.MainLib(vim.eval("self.libname"))
categories = reader.categories_str()
cat_str = ",".join('"' + c + '"' for c in categories)
vim.command('let self.children = [%s]' % cat_str)
EOF
    return self.getChildCount()
endfunction


function! s:TreeRootNode.renderToString()
    return self._renderToString(0, 0)
endfunction

function! s:TreeRootNode.displayString()
    return self.path.flagSet.renderToSTring() . self.path.displayString()
endfunction

function! s:TreeRootNode._renderToString(depth, drawText)
    let output = ""
    if a:drawText ==# 1
        let treeParts = ('  ', a:depth - 1)
        let line = treeParts . self.displayString()
        let output = output . line . "\n"
    endif
    return output
endfunction
