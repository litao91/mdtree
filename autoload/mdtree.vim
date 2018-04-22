if exists("g:loaded_mdtree_autoload")
    finish
endif
let g:loaded_mdtree_autoload = 1

function! mdtree#version()
    return '0.0.1'
endfunction

" SECTION: General Functions {{{1
"============================================================

" FUNCTION: mdtree#exec(cmd) {{{2
" Same as :exec cmd but with eventignore set for the duration
" to disable the autocommands used by mdtree (BufEnter,
" BufLeave and VimEnter)
function! mdtree#exec(cmd)
    let old_ei = &ei
    set ei=BufEnter,BufLeave,VimEnter
    exec a:cmd
    let &ei = old_ei
endfunction

" FUNCTION: mdtree#has_opt(options, name) {{{2
function! mdtree#has_opt(options, name)
    return has_key(a:options, a:name) && a:options[a:name] == 1
endfunction

" FUNCTION: mdtree#loadClassFiles() {{{2
function! mdtree#loadClassFiles()
    runtime lib/mdtree/creator.vim
    runtime lib/mdtree/path.vim
    runtime lib/mdtree/flag_set.vim
    runtime lib/mdtree/mdtree.vim
    runtime lib/mdtree/ui.vim
    runtime lib/mdtree/tree_root_node.vim
    runtime lib/mdtree/tree_cat_node.vim
    runtime lib/mdtree/tree_article_node.vim
    runtime lib/mdtree/key_map.vim
    runtime lib/mdtree/opener.vim
endfunction

function! mdtree#postSourceActions()
    call mdtree#ui_glue#createDefaultBindings()
endfunction

"FUNCTION: mdtree#runningWindows(dir) {{{2
function! mdtree#runningWindows()
    return has("win16") || has("win32") || has("win64")
endfunction

"FUNCTION: mdtree#runningCygwin(dir) {{{2
function! mdtree#runningCygwin()
    return has("win32unix")
endfunction

" SECTION: View Functions {{{1
"============================================================

"FUNCTION: mdtree#echo  {{{2
"A wrapper for :echo. Appends 'mdtree:' on the front of all messages
"
"Args:
"msg: the message to echo
function! mdtree#echo(msg)
    redraw
    echomsg "mdtree: " . a:msg
endfunction

"FUNCTION: mdtree#echoError {{{2
"Wrapper for mdtree#echo, sets the message type to errormsg for this message
"Args:
"msg: the message to echo
function! mdtree#echoError(msg)
    echohl errormsg
    call mdtree#echo(a:msg)
    echohl normal
endfunction

"FUNCTION: mdtree#echoWarning {{{2
"Wrapper for mdtree#echo, sets the message type to warningmsg for this message
"Args:
"msg: the message to echo
function! mdtree#echoWarning(msg)
    echohl warningmsg
    call mdtree#echo(a:msg)
    echohl normal
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
