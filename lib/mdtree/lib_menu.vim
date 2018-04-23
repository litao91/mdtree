if exists("g:loaded_mdtree_lib_menu")
    finish
endif
let g:loaded_mdtree_lib_menu = 1


call MDTreeAddMenuItem({'text': '(a)dd a childnode', 'shortcut': 'a', 'callback': 'MDTreeAddNode'})
call MDTreeAddMenuItem({'text': '(d)elete the current node', 'shortcut': 'd', 'callback': 'MDTreeDeleteNode'})
