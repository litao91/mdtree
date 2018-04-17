" ============================================================================
" CLASS: Creator
"
" This class is responsible for creating MDTree instances.  The new MDTree
" may be a tab tree, a window tree, or a mirrored tree.  In the process of
" creating a MDTree, it sets up all of the window and buffer options and key
" mappings etc.
" ============================================================================


let s:Creator = {}
let g:MDTreeCreator = s:Creator


function! s:Creator.createTabTree(name)
    let l:path = self._pathForString(a:name)
endfunction

" FUNCTION: s:Creator.ToggleTabTree(dir) {{{1
function! s:Creator.ToggleTabTree(dir)
    let creator = s:Creator.New()
    call creator.toggleTabTree(a:dir)
endfunction

" FUNCTION: s:Creator.New() {{{1
function! s:Creator.New()
    let newCreator = copy(self)
    return newCreator
endfunction

" FUNCTION: s:Creator._pathForString(str) {{{1
" Find a directory for the given string
function! s:Creator._pathForString(str)
    let path = {}
    let dir = a:str ==# '' ? getcwd() : a:str
    " hack to get an absolute path
    if dir =~# '^\.'
        let dir = getcwd() . g:MDTreePath.Slash() . dir
    endif
    let dir = g:MDTreePath.Resolve(dir)

    try 
        let path = g:MDTreePath.New(dir)
    catch /^MDTree.InvalidArgumentsError/
        call mdtree#echo("No directory found for " . a:str)
        return {}
    endtry
    if !path.isDirectory
        let path = path.getParent()
    endif
    return path
endfunction

" FUNCTION: s:Creator.toggleTabTree(dir) {{{1
" Toggles the NERD tree. I.e the NERD tree is open, it is closed, if it is
" closed it is restored or initialized (if it doesnt exist)
"
" Args:
" dir: the full path for the root node (is only used if the NERD tree is being
" initialized.
function! s:Creator.toggleTabTree(dir)
    call self.createTabTree(a:dir)
endfunction

" Function: s:Creator._uniq(list)   {{{1
" returns a:list without duplicates
function! s:Creator._uniq(list)
  let uniqlist = []
  for elem in a:list
    if index(uniqlist, elem) ==# -1
      let uniqlist += [elem]
    endif
  endfor
  return uniqlist
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
