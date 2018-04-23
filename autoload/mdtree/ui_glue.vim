if exists("g:loaded_mdtree_ui_glue_autoload")
    finish
endif
let g:loaded_mdtree_ui_glue_autoload = 1


function! mdtree#ui_glue#createDefaultBindings()
    let s = '<SNR>' . s:SID() . '_'
    call MDTreeAddKeyMap({'key': g:MDTreeMapActivateNode, 'scope': "CategoryNode", 'callback': s."activateCatNode"})
    call MDTreeAddKeyMap({'key': g:MDTreeMapActivateNode, 'scope': "ArticleNode", 'callback': s."activateArticleNode"})
    call MDTreeAddKeyMap({'key': g:MDTreeMapMenu, 'scope': "Node", 'callback': s."showMenu"})
endfunction

function! s:activateCatNode(catNode)
    call a:catNode.activate()
endfunction

function! s:activateArticleNode(node)
    call a:node.activate({'reuse': 'all', 'where': 'p'})
endfunction

function! s:showMenu(node)
    let mc = g:MDTreeMenuController.New(g:MDTreeMenuItem.AllEnabled())
    call mc.showMenu()
endfunction

function! mdtree#ui_glue#invokeKeyMap(key)
    call g:MDTreeKeyMap.Invoke(a:key)
endfunction



" FUNCTION: mdtree#ui_glue#setupCommands() {{{1
function! mdtree#ui_glue#setupCommands()
    " command! -n=? -complete=dir -bar MDTree :call g:MDTreeCreator.CreateTabTree('<args>')
    command! -n=? -complete=dir -bar MDTreeToggle :call g:MDTreeCreator.ToggleTabTree('<args>')
endfunction

function s:SID()
    if !exists("s:sid")
        let s:sid = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
    endif
    return s:sid
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
