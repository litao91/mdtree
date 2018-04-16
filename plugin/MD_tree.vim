" ============================================================================
" File:        NERD_tree.vim
" Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" ============================================================================
"
" SECTION: Script init stuff {{{1
"============================================================
if exists("loaded_nerd_tree")
    finish
endif
if v:version < 700
    echoerr "MDTree: this plugin requires vim >= 7. DOWNLOAD IT! You'll thank me later!"
    finish
endif
let loaded_nerd_tree = 1

"for line continuation - i.e dont want C in &cpo
let s:old_cpo = &cpo
set cpo&vim

"Function: s:initVariable() function {{{2
"This function is used to initialise a given variable to a given value. The
"variable is only initialised if it does not exist prior
"
"Args:
"var: the name of the var to be initialised
"value: the value to initialise var to
"
"Returns:
"1 if the var is set, 0 otherwise
function! s:initVariable(var, value)
    if !exists(a:var)
        exec 'let ' . a:var . ' = ' . "'" . substitute(a:value, "'", "''", "g") . "'"
        return 1
    endif
    return 0
endfunction

"SECTION: Init variable calls and other random constants {{{2
call s:initVariable("g:MDTreeGlyphReadOnly", "RO")
call s:initVariable("g:MDTreeWinPos", "left")
call s:initVariable("g:MDTreeWinSize", 31)

"init the shell commands that will be used to copy nodes, and remove dir trees
"
"SECTION: Init variable calls for key mappings {{{2
call s:initVariable("g:MDTreeMapActivateNode", "o")
call s:initVariable("g:MDTreeMapChangeRoot", "C")
call s:initVariable("g:MDTreeMapChdir", "cd")
call s:initVariable("g:MDTreeMapCloseChildren", "X")
call s:initVariable("g:MDTreeMapCloseDir", "x")
call s:initVariable("g:MDTreeMapMenu", "m")
call s:initVariable("g:MDTreeMapHelp", "?")
call s:initVariable("g:MDTreeMapJumpFirstChild", "K")
call s:initVariable("g:MDTreeMapJumpLastChild", "J")
call s:initVariable("g:MDTreeMapJumpNextSibling", "<C-j>")
call s:initVariable("g:MDTreeMapJumpParent", "p")
call s:initVariable("g:MDTreeMapJumpPrevSibling", "<C-k>")
call s:initVariable("g:MDTreeMapJumpRoot", "P")
call s:initVariable("g:MDTreeMapOpenExpl", "e")
call s:initVariable("g:MDTreeMapOpenInTab", "t")
call s:initVariable("g:MDTreeMapOpenInTabSilent", "T")
call s:initVariable("g:MDTreeMapOpenRecursively", "O")
call s:initVariable("g:MDTreeMapOpenSplit", "i")
call s:initVariable("g:MDTreeMapOpenVSplit", "s")
call s:initVariable("g:MDTreeMapPreview", "g" . MDTreeMapActivateNode)
call s:initVariable("g:MDTreeMapPreviewSplit", "g" . MDTreeMapOpenSplit)
call s:initVariable("g:MDTreeMapPreviewVSplit", "g" . MDTreeMapOpenVSplit)
call s:initVariable("g:MDTreeMapQuit", "q")
call s:initVariable("g:MDTreeMapRefresh", "r")
call s:initVariable("g:MDTreeMapRefreshRoot", "R")
call s:initVariable("g:MDTreeMapToggleBookmarks", "B")
call s:initVariable("g:MDTreeMapToggleFiles", "F")
call s:initVariable("g:MDTreeMapToggleFilters", "f")
call s:initVariable("g:MDTreeMapToggleHidden", "I")
call s:initVariable("g:MDTreeMapToggleZoom", "A")
call s:initVariable("g:MDTreeMapUpdir", "u")
call s:initVariable("g:MDTreeMapUpdirKeepOpen", "U")
call s:initVariable("g:MDTreeMapCWD", "CD")

"SECTION: Load class files{{{2
call nerdtree#loadClassFiles()

" SECTION: Commands {{{1
"============================================================
call nerdtree#ui_glue#setupCommands()

" SECTION: Auto commands {{{1
"============================================================
augroup MDTree
    "Save the cursor position whenever we close the nerd tree
    exec "autocmd BufLeave ". g:MDTreeCreator.BufNamePrefix() ."* if g:MDTree.IsOpen() | call b:MDTree.ui.saveScreenState() | endif"

    "disallow insert mode in the MDTree
    exec "autocmd BufEnter ". g:MDTreeCreator.BufNamePrefix() ."* stopinsert"
augroup END

if g:MDTreeHijackNetrw
    augroup MDTreeHijackNetrw
        autocmd VimEnter * silent! autocmd! FileExplorer
        au BufEnter,VimEnter * call nerdtree#checkForBrowse(expand("<amatch>"))
    augroup END
endif

" SECTION: Public API {{{1
"============================================================
function! MDTreeAddMenuItem(options)
    call g:MDTreeMenuItem.Create(a:options)
endfunction

function! MDTreeAddMenuSeparator(...)
    let opts = a:0 ? a:1 : {}
    call g:MDTreeMenuItem.CreateSeparator(opts)
endfunction

function! MDTreeAddSubmenu(options)
    return g:MDTreeMenuItem.Create(a:options)
endfunction

function! MDTreeAddKeyMap(options)
    call g:MDTreeKeyMap.Create(a:options)
endfunction

function! MDTreeRender()
    call nerdtree#renderView()
endfunction

function! MDTreeFocus()
    if g:MDTree.IsOpen()
        call g:MDTree.CursorToTreeWin()
    else
        call g:MDTreeCreator.ToggleTabTree("")
    endif
endfunction

function! MDTreeCWD()
    call MDTreeFocus()
    call nerdtree#ui_glue#chRootCwd()
endfunction

function! MDTreeAddPathFilter(callback)
    call g:MDTree.AddPathFilter(a:callback)
endfunction

" SECTION: Post Source Actions {{{1
call nerdtree#postSourceActions()

"reset &cpo back to users setting
let &cpo = s:old_cpo

" vim: set sw=4 sts=4 et fdm=marker:
