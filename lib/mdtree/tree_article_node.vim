let s:TreeArticleNode = {}
let g:MDTreeArticleNode = s:TreeArticleNode

function! s:TreeArticleNode.New(title, uuid, mdtree)
    let newArticleNode = copy(self)
    let newArticleNode.title = a:title
    let newArticleNode.uuid = a:uuid
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

function! s:TreeArticleNode.activate()
endfunction

