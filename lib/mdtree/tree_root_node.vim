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


function! s:TreeRootNode._initChildren(silent)
    let self.children = []
    return 0
endfunction


function! s:TreeRootNode.renderToString()
    return self._renderToString(0, 0)
endfunction

function! s:TreeRootNode._renderToString(depth, drawText)
    let output = "this is a test"
    return output
endfunction
