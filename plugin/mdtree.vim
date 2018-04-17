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

if !exists("g:MDTreeSortOrder")
    let g:MDTreeSortOrder = ['\/$', '*', '\.swp$', '\.bak$', '\~$']
else
    if count(g:MDTreeSortOrder, '*') < 1
        call add(g:MDTreeSortOrder, '*')
    endif
endif

call mdtree#loadClassFiles()
call mdtree#ui_glue#setupCommands()

let &cpo = s:old_cpo