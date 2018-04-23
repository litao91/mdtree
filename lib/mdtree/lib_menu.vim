if exists("g:loaded_mdtree_lib_menu")
    finish
endif
let g:loaded_mdtree_lib_menu = 1


call MDTreeAddMenuItem({'text': '(a)dd a childnode', 'shortcut': 'a', 'callback': 'MDTreeAddNode'})
call MDTreeAddMenuItem({'text': '(d)elete the current node', 'shortcut': 'd', 'callback': 'MDTreeDeleteNode'})

function! MDTreeAddNode()
    let curCatNode = b:MDTree.root.GetSelected()
    let newNodeName = input("ChildNode Name\n" , "" , "file")
    if newNodeName ==# ''
        call mdtree#echo("Node creation aborted".)
        return
    endif
    try

endfunction

