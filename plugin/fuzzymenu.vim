
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
xnoremap <silent> <Plug>FzmVisual :call fuzzymenu#RunVisual()<cr>

""
" @setting g:fuzzymenu_auto_add
" Automatically add menu items. Note: I'll break these up in future into
" several categories
let g:fuzzymenu_auto_add = get(g:, 'fuzzymenu_auto_add', 1)

if g:fuzzymenu_auto_add

if &rtp =~ 'vim-lsp'
  call fuzzymenu#Add('Go to definition', {'exec': 'LspDefinition', 'tags': ['LSP']})
  call fuzzymenu#Add('Find references', {'exec': 'LspReferences', 'tags': ['LSP']})
  call fuzzymenu#Add('Rename', {'exec': 'LspRename', 'tags': ['LSP']})
  call fuzzymenu#Add('Organize imports', {'exec': 'LspCodeActionSync source.organizeImports', 'tags': ['LSP']})
  call fuzzymenu#Add('Go to implementation', {'exec': 'LspImplementation', 'tags': ['LSP']})
endif

if &rtp =~ 'vim-fugitive'
  call fuzzymenu#Add('Find commit', {'exec': 'Commits', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['git']})
  call fuzzymenu#Add('Find commit in current buffer', {'exec': 'BCommits', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['git']})
  call fuzzymenu#Add('Open file', {'exec': 'GFiles', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['git']})
  call fuzzymenu#Add('Find in files', {'exec': 'GGrep', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['git']})
  call fuzzymenu#Add('Browse to file/selection', {'exec': 'GBrowse', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['git', 'github']})
endif

" basic options
call fuzzymenu#Add('Set case-sensitive searches', {'exec': 'set noignorecase'})
call fuzzymenu#Add('Set case-insensitive searches', {'exec': 'set ignorecase'})
call fuzzymenu#Add('Hide line numbers', {'exec': 'set nonumber'})
call fuzzymenu#Add('Show line numbers', {'exec': 'set number'})
call fuzzymenu#Add('Hide whitespace characters', {'exec': 'set nolist'})
call fuzzymenu#Add('Show whitespace characters', {'exec': 'set list'})

" common editor features
call fuzzymenu#Add('Select all', {'exec': 'normal! ggVG'})
call fuzzymenu#Add('Yank (copy) all', {'exec': '%y'})
call fuzzymenu#Add('Yank (copy) selection', {'exec': '%y', 'modes': 'v'})
call fuzzymenu#Add('Delete all', {'exec': '%d'})

""" fzf tools
call fuzzymenu#Add('Key mappings', {'exec': 'Maps', 'after': 'call fuzzymenu#InsertMode()', 'help': 'vim key mappings', 'tags': ['fzf']})
call fuzzymenu#Add('Vim commands', {'exec': 'Commands', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['fzf']})
call fuzzymenu#Add('Open recent file', {'exec': 'History', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['fzf']})
call fuzzymenu#Add('Recent commands', {'exec': 'History:', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['fzf']})
call fuzzymenu#Add('Recent searches', {'exec': 'History/', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['fzf']})
call fuzzymenu#Add('Help', {'exec': 'Helptags', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['fzf']})
call fuzzymenu#Add('Find in open buffers (files)', {'exec': 'Lines', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['fzf']})
call fuzzymenu#Add('Find (in current buffer)', {'exec': 'BLines', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['fzf']})
call fuzzymenu#Add('Open file', {'exec': 'Files', 'after': 'call fuzzymenu#InsertMode()', 'tags': ['fzf']})


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
"" An fzf function which is recommended in fzf docs
"" Find a file using git as a base dir
command! -bang -nargs=* GGrep
\ call fzf#vim#grep(
\   'git grep --line-number '.shellescape(<q-args>), 0,
\   fzf#vim#with_preview({ 'dir': systemlist('git rev-parse --show-toplevel')[0] }), <bang>0)
