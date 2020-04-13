nnoremap <buffer> <silent> <Plug>Fzm :call fzm#Run()<cr>

if &rtp =~ 'vim-lsp'
  call fzm#Add('LSP: Go To Definition', {'exec': 'LspDefinition'})
  call fzm#Add('LSP: Find References', {'exec': 'LspReferences'})
  call fzm#Add('LSP: Rename', {'exec': 'LspRename'})
endif

if &rtp =~ 'vim-fugitive'
  call fzm#Add('Find Commit', {'exec': 'Commits', 'mode': 'insert'})
  call fzm#Add('Find Commit (Current Buffer)', {'exec': 'BCommits', 'mode': 'insert'})
  call fzm#Add('Find git File', {'exec': 'GFiles', 'mode': 'insert'})
  call fzm#Add('Git Grep', {'exec': 'GGrep', 'mode': 'insert'})
endif

call fzm#Add('No Ignore Case', {'exec': 'set noignorecase'})
call fzm#Add('Ignore Case', {'exec': 'set ignorecase'})

""" fzf tools
call fzm#Add('Key Maps', {'exec': 'Maps', 'mode': 'insert'})
call fzm#Add('Ex Commands', {'exec': 'Commands', 'mode': 'insert'})
call fzm#Add('History', {'exec': 'History', 'mode': 'insert'})
call fzm#Add('Command History', {'exec': 'History:', 'mode': 'insert'})
call fzm#Add('Search History', {'exec': 'History/', 'mode': 'insert'})
call fzm#Add('Help Tags', {'exec': 'Helptags', 'mode': 'insert'})
call fzm#Add('Lines in loaded buffers', {'exec': 'Lines', 'mode': 'insert'})
call fzm#Add('Lines in current buffer', {'exec': 'BLines', 'mode': 'insert'})


if !hasmapto('<Plug>Fzm', 'n')
   nmap <buffer> <Leader><Leader> <Plug>Fzm
endif

command -nargs=0 -buffer Fzm call fzm#Run()<cr>
