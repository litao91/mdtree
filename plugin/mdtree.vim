" ============================================================ 
" SECTION: Script init stuff
" ============================================================
if exists("load_md_tree")
    finish
endif

let load_md_tree = 1

"for line continuation
let s:old_cpo = &cpo
set cpo&vim

" Returns:
" 1 if the var is set, 0 otherwise
function! s:initVariable(var, value)
    if !exists(a:var)
        exec 'let ' . a:var . ' = ' . "'" . substitute(a:value, "'", "''", "g") . "'"
        return 1
    endif
    return 0
endfunction

call s:initVariable("g:MDTreeGlyphReadonly", "RO")

call s:initVariable("g:MDTreeWinPos", "left")
call s:initVariable("g:MDTreeWinSize", 31)
call s:initVariable("g:MDTreeLibName", "mainlib.db")
call s:initVariable("g:MDTreeDirArrowExpandable", "▸")
call s:initVariable("g:MDTreeDirArrowCollapsible", "▾")
call s:initVariable("g:MDTreeMapActivateNode", "o")
call s:initVariable("g:MDTreeQuitOnOpen", 0)
call s:initVariable("g:MDTreeMapMenu", "m")

let g:plugin_path = expand('<sfile>:p:h')

if !exists("g:MDTreeSortOrder")
    let g:MDTreeSortOrder = ['\/$', '*', '\.swp$', '\.bak$', '\~$']
else
    if count(g:MDTreeSortOrder, '*') < 1
        call add(g:MDTreeSortOrder, '*')
    endif
endif

" SECTION: Public API {{{1
" =======================================================================
function! MDTreeAddKeyMap(options)
    call g:MDTreeKeyMap.Create(a:options)
endfunction

function! MDTreeAddMenuItem(options)
    call g:MDTreeMenuItem.Create(a:options)
endfunction

call mdtree#loadClassFiles()
call mdtree#ui_glue#setupCommands()
call mdtree#postSourceActions()

let &cpo = s:old_cpo
