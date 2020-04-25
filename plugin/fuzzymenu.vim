
""
" @section Introduction, intro
" {fuzzymenu}{1} is a fuzzy-finder menu for vim, built on top of {fzf}{2}. Discover vim features easily, just invoke fuzzymenu and start typing. See the fuzzymenu.vim README for more background.
"
" {1} https://github.com/laher/fuzzymenu.vim
" {2} https://github.com/junegunn/fzf


nnoremap <buffer> <silent> <Plug>Fzm :call fuzzymenu#Run()<cr>

let auto_add = get(g:, 'fuzzymenu_auto_add', 1)
  
if auto_add
  if &rtp =~ 'vim-lsp'
    call fuzzymenu#Add('LSP: go to definition', {'exec': 'LspDefinition'})
    call fuzzymenu#Add('LSP: find references', {'exec': 'LspReferences'})
    call fuzzymenu#Add('LSP: rename', {'exec': 'LspRename'})
    call fuzzymenu#Add('LSP: organize imports', {'exec': 'LspCodeActionSync source.organizeImports'})
    call fuzzymenu#Add('LSP: go to implementation', {'exec': 'LspImplementation'})
  endif

  if &rtp =~ 'vim-fugitive'
    call fuzzymenu#Add('Git: find commit', {'exec': 'Commits', 'mode': 'insert'})
    call fuzzymenu#Add('Git: find commit in current buffer', {'exec': 'BCommits', 'mode': 'insert'})
    call fuzzymenu#Add('Git: find file', {'exec': 'GFiles', 'mode': 'insert'})
    call fuzzymenu#Add('Git: grep', {'exec': 'GGrep', 'mode': 'insert'})
    call fuzzymenu#Add('Git: browse', {'exec': 'GBrowse', 'mode': 'insert'})
  endif

  " basic options
  call fuzzymenu#Add('Set case-sensitive searches', {'exec': 'set noignorecase'})
  call fuzzymenu#Add('Set case-insensitive searches', {'exec': 'set ignorecase'})
  call fuzzymenu#Add('Hide line numbers', {'exec': 'set nonumber'})
  call fuzzymenu#Add('Show line numbers', {'exec': 'set number'})
  call fuzzymenu#Add('Hide whitespace characters', {'exec': 'set nolist'})
  call fuzzymenu#Add('Show whitespace characters', {'exec': 'set list'})

  """ fzf tools
  call fuzzymenu#Add('Key mappings', {'exec': 'Maps', 'mode': 'insert', 'help': 'vim key mappings'})
  call fuzzymenu#Add('Vim commands', {'exec': 'Commands', 'mode': 'insert'})
  call fuzzymenu#Add('Recent files', {'exec': 'History', 'mode': 'insert'})
  call fuzzymenu#Add('Recent commands', {'exec': 'History:', 'mode': 'insert'})
  call fuzzymenu#Add('Recent searches', {'exec': 'History/', 'mode': 'insert'})
  call fuzzymenu#Add('Help', {'exec': 'Helptags', 'mode': 'insert'})
  call fuzzymenu#Add('Find lines in loaded buffers', {'exec': 'Lines', 'mode': 'insert'})
  call fuzzymenu#Add('Find lines in current buffer', {'exec': 'BLines', 'mode': 'insert'})

""
" @section Mappings, mappings
" There are one normal-mode mapping, "<Leader><Leader>" to invoke fuzzymenu
  if !hasmapto('<Plug>Fzm', 'n')
     nmap <buffer> <Leader><Leader> <Plug>Fzm
  endif
endif

""
" @section Commands, commands
" There is a single command, @command(Fzm), to invoke fuzzymenu.

""
" Fzm invokes fuzzymenu 
command -nargs=0 -buffer Fzm call fuzzymenu#Run()<cr>
