if exists("g:loaded_MDTree_autoload")
    finish
endif
let g:loaded_MDTree_autoload = 1

function! MDTree#version()
    return '0.0.1'
endfunction

" SECTION: General Functions {{{1
"============================================================

"FUNCTION: MDTree#checkForBrowse(dir) {{{2
"inits a window tree in the current buffer if appropriate
function! MDTree#checkForBrowse(dir)
    if !isdirectory(a:dir)
        return
    endif

    if s:reuseWin(a:dir)
        return
    endif

    call g:MDTreeCreator.CreateWindowTree(a:dir)
endfunction

"FUNCTION: s:reuseWin(dir) {{{2
"finds a MDTree buffer with root of dir, and opens it.
function! s:reuseWin(dir) abort
    let path = g:MDTreePath.New(fnamemodify(a:dir, ":p"))

    for i in range(1, bufnr("$"))
        unlet! nt
        let nt = getbufvar(i, "MDTree")
        if empty(nt)
            continue
        endif

        if nt.isWinTree() && nt.root.path.equals(path)
            call nt.setPreviousBuf(bufnr("#"))
            exec "buffer " . i
            return 1
        endif
    endfor

    return 0
endfunction

" FUNCTION: MDTree#completeBookmarks(A,L,P) {{{2
" completion function for the bookmark commands
function! MDTree#completeBookmarks(A,L,P)
    return filter(g:MDTreeBookmark.BookmarkNames(), 'v:val =~# "^' . a:A . '"')
endfunction

"FUNCTION: MDTree#compareNodes(dir) {{{2
function! MDTree#compareNodes(n1, n2)
    return a:n1.path.compareTo(a:n2.path)
endfunction

"FUNCTION: MDTree#compareNodesBySortKey(n1, n2) {{{2
function! MDTree#compareNodesBySortKey(n1, n2)
    let sortKey1 = a:n1.path.getSortKey()
    let sortKey2 = a:n2.path.getSortKey()

    let i = 0
    while i < min([len(sortKey1), len(sortKey2)])
        " Compare chunks upto common length.
        " If chunks have different type, the one which has
        " integer type is the lesser.
        if type(sortKey1[i]) == type(sortKey2[i])
            if sortKey1[i] <# sortKey2[i]
                return - 1
            elseif sortKey1[i] ># sortKey2[i]
                return 1
            endif
        elseif sortKey1[i] == type(0)
            return -1
        elseif sortKey2[i] == type(0)
            return 1
        endif
        let i = i + 1
    endwhile

    " Keys are identical upto common length.
    " The key which has smaller chunks is the lesser one.
    if len(sortKey1) < len(sortKey2)
        return -1
    elseif len(sortKey1) > len(sortKey2)
        return 1
    else
        return 0
    endif
endfunction

" FUNCTION: MDTree#deprecated(func, [msg]) {{{2
" Issue a deprecation warning for a:func. If a second arg is given, use this
" as the deprecation message
function! MDTree#deprecated(func, ...)
    let msg = a:0 ? a:func . ' ' . a:1 : a:func . ' is deprecated'

    if !exists('s:deprecationWarnings')
        let s:deprecationWarnings = {}
    endif
    if !has_key(s:deprecationWarnings, a:func)
        let s:deprecationWarnings[a:func] = 1
        echomsg msg
    endif
endfunction

" FUNCTION: MDTree#exec(cmd) {{{2
" Same as :exec cmd but with eventignore set for the duration
" to disable the autocommands used by MDTree (BufEnter,
" BufLeave and VimEnter)
function! MDTree#exec(cmd)
    let old_ei = &ei
    set ei=BufEnter,BufLeave,VimEnter
    exec a:cmd
    let &ei = old_ei
endfunction

" FUNCTION: MDTree#has_opt(options, name) {{{2
function! MDTree#has_opt(options, name)
    return has_key(a:options, a:name) && a:options[a:name] == 1
endfunction

" FUNCTION: MDTree#loadClassFiles() {{{2
function! MDTree#loadClassFiles()
    runtime lib/MDTree/path.vim
    runtime lib/MDTree/menu_controller.vim
    runtime lib/MDTree/menu_item.vim
    runtime lib/MDTree/key_map.vim
    runtime lib/MDTree/bookmark.vim
    runtime lib/MDTree/tree_file_node.vim
    runtime lib/MDTree/tree_dir_node.vim
    runtime lib/MDTree/opener.vim
    runtime lib/MDTree/creator.vim
    runtime lib/MDTree/flag_set.vim
    runtime lib/MDTree/MDTree.vim
    runtime lib/MDTree/ui.vim
    runtime lib/MDTree/event.vim
    runtime lib/MDTree/notifier.vim
endfunction

" FUNCTION: MDTree#postSourceActions() {{{2
function! MDTree#postSourceActions()
    call g:MDTreeBookmark.CacheBookmarks(1)
    call MDTree#ui_glue#createDefaultBindings()

    "load all MDTree plugins
    runtime! MDTree_plugin/**/*.vim
endfunction

"FUNCTION: MDTree#runningWindows(dir) {{{2
function! MDTree#runningWindows()
    return has("win16") || has("win32") || has("win64")
endfunction

"FUNCTION: MDTree#runningCygwin(dir) {{{2
function! MDTree#runningCygwin()
    return has("win32unix")
endfunction

" SECTION: View Functions {{{1
"============================================================

"FUNCTION: MDTree#echo  {{{2
"A wrapper for :echo. Appends 'MDTree:' on the front of all messages
"
"Args:
"msg: the message to echo
function! MDTree#echo(msg)
    redraw
    echomsg "MDTree: " . a:msg
endfunction

"FUNCTION: MDTree#echoError {{{2
"Wrapper for MDTree#echo, sets the message type to errormsg for this message
"Args:
"msg: the message to echo
function! MDTree#echoError(msg)
    echohl errormsg
    call MDTree#echo(a:msg)
    echohl normal
endfunction

"FUNCTION: MDTree#echoWarning {{{2
"Wrapper for MDTree#echo, sets the message type to warningmsg for this message
"Args:
"msg: the message to echo
function! MDTree#echoWarning(msg)
    echohl warningmsg
    call MDTree#echo(a:msg)
    echohl normal
endfunction

"FUNCTION: MDTree#renderView {{{2
function! MDTree#renderView()
    call b:MDTree.render()
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
