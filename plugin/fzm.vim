nnoremap <buffer> <silent> <Plug>Fzm :call fzm#Run()<cr>

function! CaseIns()
  set ignorecase
endfunction

function! CaseSens()
  set noignorecase
endfunction

if &rtp =~ 'todo.vim'
  call fzm#Add('Todo Prompt', {'exec': 'call todo#prompt()'})
  call fzm#Add('Todo Split', {'exec': 'call todo#split()'})
  call fzm#Add('Todo Refile', {'exec': 'call todo#refile()'})
endif

if &rtp =~ 'vim-lsp'
  call fzm#Add('Go To Definition', {'exec': 'LspDefinition'})
  call fzm#Add('Find References', {'exec': 'LspReferences'})
  call fzm#Add('Rename', {'exec': 'LspRename'})
endif

if &rtp =~ 'vim-fugitive'
  call fzm#Add('Find Commit', {'exec': 'call fzm#WithInsertMode("Commits")'})
  call fzm#Add('Find git File', {'exec': 'call fzm#WithInsertMode("GFiles")'})
  call fzm#Add('Git Grep', {'exec': 'call fzm#WithInsertMode("GGrep")'})
endif

if &rtp =~ 'gothx.vim'
  call fzm#Add('Go: Run', {'exec': 'call gothx#run#Run()', 'for': 'go'})
  call fzm#Add('Go: Test', {'exec': 'call gothx#test#Test()', 'for': 'go'})
  call fzm#Add('Go: Keyify', {'exec': 'call gothx#keyify#Keyify()', 'for': 'go'})
endif

call fzm#Add('No Ignore Case', {'exec': 'call CaseSens()'})
call fzm#Add('Ignore Case', {'exec': 'call CaseIns()'})

if !hasmapto('<Plug>Fzm', 'n')
   nmap <buffer> <Leader><Leader> <Plug>Fzm
endif

command -nargs=0 -buffer Fzm call fzm#Run()<cr>
