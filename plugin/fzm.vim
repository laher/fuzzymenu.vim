nnoremap <buffer> <silent> <Plug>Fzm :call fzm#Run()<cr>

if &rtp =~ 'vim-lsp'
  call fzm#Add('LSP: go to definition', {'exec': 'LspDefinition'})
  call fzm#Add('LSP: find references', {'exec': 'LspReferences'})
  call fzm#Add('LSP: rename', {'exec': 'LspRename'})
  call fzm#Add('LSP: organize imports', {'exec': 'LspCodeActionSync source.organizeImports'})
  call fzm#Add('LSP: go to implementation', {'exec': 'LspImplementation'})
endif

if &rtp =~ 'vim-fugitive'
  call fzm#Add('Git: find commit', {'exec': 'Commits', 'mode': 'insert'})
  call fzm#Add('Git: find commit in current buffer', {'exec': 'BCommits', 'mode': 'insert'})
  call fzm#Add('Git: find file', {'exec': 'GFiles', 'mode': 'insert'})
  call fzm#Add('Git: grep', {'exec': 'GGrep', 'mode': 'insert'})
  call fzm#Add('Git: browse', {'exec': 'GBrowse', 'mode': 'insert'})
endif

" basic options
call fzm#Add('No ignore case (case-sensitive)', {'exec': 'set noignorecase'})
call fzm#Add('Ignore case (case-insensitive)', {'exec': 'set ignorecase'})
call fzm#Add('set nonumber (hide line numbers)', {'exec': 'set nonumber'})
call fzm#Add('set number (show line numbers)', {'exec': 'set number'})
call fzm#Add('set nolist (hide whitespace characters)', {'exec': 'set nolist'})
call fzm#Add('set list (show whitespace characters)', {'exec': 'set list'})

""" fzf tools
call fzm#Add('Key mappings', {'exec': 'Maps', 'mode': 'insert'})
call fzm#Add('Ex commands', {'exec': 'Commands', 'mode': 'insert'})
call fzm#Add('History', {'exec': 'History', 'mode': 'insert'})
call fzm#Add('Command history', {'exec': 'History:', 'mode': 'insert'})
call fzm#Add('Search history', {'exec': 'History/', 'mode': 'insert'})
call fzm#Add('Help tags', {'exec': 'Helptags', 'mode': 'insert'})
call fzm#Add('Lines in loaded buffers', {'exec': 'Lines', 'mode': 'insert'})
call fzm#Add('Lines in current buffer', {'exec': 'BLines', 'mode': 'insert'})


if !hasmapto('<Plug>Fzm', 'n')
   nmap <buffer> <Leader><Leader> <Plug>Fzm
endif

command -nargs=0 -buffer Fzm call fzm#Run()<cr>
