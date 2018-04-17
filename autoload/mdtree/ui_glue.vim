if exists("g:loaded_mdtree_ui_glue_autoload")
    finish
endif
let g:loaded_mdtree_ui_glue_autoload = 1


" FUNCTION: mdtree#ui_glue#setupCommands() {{{1
function! mdtree#ui_glue#setupCommands()
    command! -n=? -complete=dir -bar MDTree :call g:MDTreeCreator.CreateTabTree('<args>')
    command! -n=? -complete=dir -bar MDTreeToggle :call g:MDTreeCreator.ToggleTabTree('<args>')
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
