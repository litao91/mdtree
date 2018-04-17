let s:tree_up_dir_line = '.. (up a dir)'
syn match MDTreeIgnore #\~#
exec 'syn match MDTreeIgnore #\['.g:MDTreeGlyphReadOnly.'\]#'

"highlighting for the .. (up dir) line at the top of the tree
execute "syn match MDTreeUp #\\V". s:tree_up_dir_line ."#"

"quickhelp syntax elements
syn match MDTreeHelpKey #" \{1,2\}[^ ]*:#ms=s+2,me=e-1
syn match MDTreeHelpKey #" \{1,2\}[^ ]*,#ms=s+2,me=e-1
syn match MDTreeHelpTitle #" .*\~$#ms=s+2,me=e-1
syn match MDTreeToggleOn #(on)#ms=s+1,he=e-1
syn match MDTreeToggleOff #(off)#ms=e-3,me=e-1
syn match MDTreeHelpCommand #" :.\{-}\>#hs=s+3
syn match MDTreeHelp  #^".*# contains=MDTreeHelpKey,MDTreeHelpTitle,MDTreeIgnore,MDTreeToggleOff,MDTreeToggleOn,MDTreeHelpCommand

"highlighting for sym links
syn match MDTreeLinkTarget #->.*# containedin=MDTreeDir,MDTreeFile
syn match MDTreeLinkFile #.* ->#me=e-3 containedin=MDTreeFile
syn match MDTreeLinkDir #.*/ ->#me=e-3 containedin=MDTreeDir

"highlighing for directory nodes and file nodes
syn match MDTreeDirSlash #/# containedin=MDTreeDir

exec 'syn match MDTreeClosable #' . escape(g:MDTreeDirArrowCollapsible, '~') . '\ze .*/# containedin=MDTreeDir,MDTreeFile'
exec 'syn match MDTreeOpenable #' . escape(g:MDTreeDirArrowExpandable, '~') . '\ze .*/# containedin=MDTreeDir,MDTreeFile'

let s:dirArrows = escape(g:MDTreeDirArrowCollapsible, '~]\-').escape(g:MDTreeDirArrowExpandable, '~]\-')
exec 'syn match MDTreeDir #[^'.s:dirArrows.' ].*/#'
syn match MDTreeExecFile  #^ .*\*\($\| \)# contains=MDTreeRO,MDTreeBookmark
exec 'syn match MDTreeFile  #^[^"\.'.s:dirArrows.'] *[^'.s:dirArrows.']*# contains=MDTreeLink,MDTreeRO,MDTreeBookmark,MDTreeExecFile'

"highlighting for readonly files
exec 'syn match MDTreeRO # *\zs.*\ze \['.g:MDTreeGlyphReadOnly.'\]# contains=MDTreeIgnore,MDTreeBookmark,MDTreeFile'

syn match MDTreeFlags #^ *\zs\[.\]# containedin=MDTreeFile,MDTreeExecFile
syn match MDTreeFlags #\[.\]# containedin=MDTreeDir

syn match MDTreeCWD #^[</].*$#

"highlighting for bookmarks
syn match MDTreeBookmark # {.*}#hs=s+1

"highlighting for the bookmarks table
syn match MDTreeBookmarksLeader #^>#
syn match MDTreeBookmarksHeader #^>-\+Bookmarks-\+$# contains=MDTreeBookmarksLeader
syn match MDTreeBookmarkName #^>.\{-} #he=e-1 contains=MDTreeBookmarksLeader
syn match MDTreeBookmark #^>.*$# contains=MDTreeBookmarksLeader,MDTreeBookmarkName,MDTreeBookmarksHeader

hi def link MDTreePart Special
hi def link MDTreePartFile Type
hi def link MDTreeExecFile Title
hi def link MDTreeDirSlash Identifier

hi def link MDTreeBookmarksHeader statement
hi def link MDTreeBookmarksLeader ignore
hi def link MDTreeBookmarkName Identifier
hi def link MDTreeBookmark normal

hi def link MDTreeHelp String
hi def link MDTreeHelpKey Identifier
hi def link MDTreeHelpCommand Identifier
hi def link MDTreeHelpTitle Macro
hi def link MDTreeToggleOn Question
hi def link MDTreeToggleOff WarningMsg

hi def link MDTreeLinkTarget Type
hi def link MDTreeLinkFile Macro
hi def link MDTreeLinkDir Macro

hi def link MDTreeDir Directory
hi def link MDTreeUp Directory
hi def link MDTreeFile Normal
hi def link MDTreeCWD Statement
hi def link MDTreeOpenable Directory
hi def link MDTreeClosable Directory
hi def link MDTreeIgnore ignore
hi def link MDTreeRO WarningMsg
hi def link MDTreeBookmark Statement
hi def link MDTreeFlags Number

hi def link MDTreeCurrentNode Search
