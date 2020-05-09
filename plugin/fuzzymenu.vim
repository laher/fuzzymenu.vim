
""
" @section Introduction, intro
" {fuzzymenu}{1} is a fuzzy-finder menu for vim, built on top of {fzf}{2}. Discover vim features easily, just invoke fuzzymenu and start typing. See the fuzzymenu.vim README for more background.
"
" {1} https://github.com/laher/fuzzymenu.vim
" {2} https://github.com/junegunn/fzf
"
" See also, |fzf|

""
" Open fuzzymenu in normal mode.
nnoremap <silent> <Plug>Fzm :call fuzzymenu#Run({})<cr>
""
" Open fuzzymenu in normal mode.
xnoremap <silent> <Plug>FzmVisual :call fuzzymenu#Run({'visual':1})<cr>

""
" @setting g:fuzzymenu_auto_add
" Automatically add menu items. Note: I'll break these up in future into
" several categories
let g:fuzzymenu_auto_add = get(g:, 'fuzzymenu_auto_add', 1)

if g:fuzzymenu_auto_add

" vim-lsp mappings
if &rtp =~ 'vim-lsp'
  call fuzzymenu#AddAll({
        \ 'Go to definition': {'exec': 'LspDefinition'},
        \ 'Find references': {'exec': 'LspReferences'},
        \ 'Rename': {'exec': 'LspRename'},
        \ 'Organize imports': {'exec': 'LspCodeActionSync source.organizeImports'},
        \ 'Go to implementation': {'exec': 'LspImplementation'},
      \ },
      \ {'tags': ['lsp', 'vim-lsp']})
endif

" fuzzymenu
" git mappings
if &rtp =~ 'vim-fugitive'
  call fuzzymenu#AddAll({
        \ 'Find commit': {'exec': 'Commits'},
        \ 'Find commit in current buffer': {'exec': 'BCommits'},
        \ 'Open file': {'exec': 'GFiles'},
        \ 'Find in files': {'exec': 'GGrep'},
        \ 'Find word under cursor as filename': {'exec': 'call fuzzymenu#GitFileUnderCursor()'}, 
        \ 'Find word under cursor in files': {'exec': 'call fuzzymenu#GitGrepUnderCursor()'},
      \ },
      \ {'after': 'call fuzzymenu#InsertMode()', 'tags': ['git', 'fzf']})
  " this one is also tagged github
  call fuzzymenu#Add('Browse to file/selection', {'exec': 'GBrowse', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['git', 'github', 'fzf']})

endif

" basic options
call fuzzymenu#Add('Set case-sensitive searches', {'exec': 'set noignorecase'})
call fuzzymenu#Add('Set case-insensitive searches', {'exec': 'set ignorecase'})
call fuzzymenu#Add('Hide line numbers', {'exec': 'set nonumber'})
call fuzzymenu#Add('Show line numbers', {'exec': 'set number'})
call fuzzymenu#Add('Hide whitespace characters', {'exec': 'set nolist'})
call fuzzymenu#Add('Show whitespace characters', {'exec': 'set list'})
call fuzzymenu#Add('Undo', {'exec': 'normal! u'})
call fuzzymenu#Add('Redo', {'exec': 'normal! <c-r>'})

" common editor features
call fuzzymenu#Add('Select all', {'exec': 'normal! ggVG'})
"call fuzzymenu#Add('Yank (copy) all', {'exec': '%y'})
"call fuzzymenu#Add('Yank (copy) selection', {'exec': '%y', 'modes': 'v'})
"call fuzzymenu#Add('Delete all', {'exec': '%d'})
call fuzzymenu#Add('Find word under cursor', {'exec': 'normal! *'})
call fuzzymenu#Add('Open file under cursor', {'exec': 'normal! gf'})
call fuzzymenu#Add('Browse to link under cursor', {'exec': 'call netrw#BrowseX(expand("<cWORD>"),0)', 'exec-hint': 'normal! gx'})

" normal mode commands and motions
call fuzzymenu#AddAll({
      \ 'Yank (copy) a text object': {'exec': 'call fuzzymenu#normal#Motions("y")'},
      \ 'Delete (cut) a text object': {'exec': 'call fuzzymenu#normal#Motions("d")'},
      \ 'Change (cut a text object and switch to insert)': {'exec': 'call fuzzymenu#normal#Motions("c")'},
    \ },
    \ {'after': 'call fuzzymenu#InsertMode()', 'tags': ['normal','fzf']})


""" fzf tools
call fuzzymenu#AddAll({
      \ 'Key mappings': {'exec': 'Maps', 'help': 'vim key mappings'},
      \ 'Vim commands': {'exec': 'Commands'},
      \ 'Open recent file': {'exec': 'History'},
      \ 'Recent commands': {'exec': 'History:'},
      \ 'Recent searches': {'exec': 'History/'},
      \ 'Help': {'exec': 'Helptags'},
      \ 'Find in open buffers (files)': {'exec': 'Lines'},
      \ 'Find (in current buffer)': {'exec': 'BLines'},
      \ 'Open file': {'exec': 'Files'},
    \ },
    \ {'after': 'call fuzzymenu#InsertMode()', 'tags': ['fzf']})

" vim-go. (see also gothx.vim) 
" NOTE: vim-go mappings won't load when loading plugins on demand (this is not a 'go'
" file so vim-go may not be loaded). Considering options ...
call fuzzymenu#AddAll({
        \ 'Run': {'exec': 'GoRun'},
        \ 'Test': {'exec': 'GoTest'},
        \ 'Keyify (specify keys in structs)': {'exec': 'GoKeyify'},
        \ 'IfErr': {'exec': 'GoIfErr'},
        \ 'Fill Struct': {'exec': 'GoFillStruct'},
        \ 'Play (launch in browser)': {'exec': 'GoPlay'},
        \ 'Alternate to/from test file': {'exec': 'GoAlternate'},
      \ },
      \ {'for': {'ft': 'go', 'rtp': 'vim-go'}, 'tags':['go','vim-go']})

""
" @section Mappings, mappings
" There are one normal-mode mapping, "<Leader><Leader>" to invoke fuzzymenu
if !hasmapto('<Plug>Fzm', 'n')
   nmap <Leader><Leader> <Plug>Fzm
endif

if !hasmapto('<Plug>Fzm', 'v')
   xmap <Leader><Leader> <Plug>FzmVisual
endif

endif

""
" @section Commands, commands
" There is a single command, @command(Fzm), to invoke fuzzymenu.

""
" Fzm invokes fuzzymenu 
command -bang -nargs=0 -buffer Fzm call fuzzymenu#Run({'fullscreen': <bang>0})

""
" GGrep finds a file using git as a base dir
" GGrep runs fzf#vim#grep with git-grep. This is recommended in fzf docs
command! -bang -nargs=* GGrep
\ call fzf#vim#grep(
\   'git grep --line-number '.shellescape(<q-args>), 0,
\   fzf#vim#with_preview({ 'dir': systemlist('git rev-parse --show-toplevel')[0] }), <bang>0)

