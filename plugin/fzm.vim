nnoremap <buffer> <silent> <Plug>Fzm :call fzm#Run()<cr>

function! CaseIns()
  set ignorecase
endfunction

function! CaseSens()
  set noignorecase
endfunction

if &rtp =~ 'todo.vim'
  call fzm#Add('Todo: Prompt', {'exec': 'call todo#Prompt()'})
  call fzm#Add('Todo: Split', {'exec': 'call todo#Split()'})
  call fzm#Add('Todo: Refile', {'exec': 'call todo#Refile()', 'mode': 'insert', 'for': 'md'})
  call fzm#Add('Todo: Chooser', {'exec': 'call todo#FzTodo()', 'mode': 'insert'})
endif

if &rtp =~ 'vim-lsp'
  call fzm#Add('LSP: Go To Definition', {'exec': 'LspDefinition'})
  call fzm#Add('LSP: Find References', {'exec': 'LspReferences'})
  call fzm#Add('LSP: Rename', {'exec': 'LspRename'})
endif

if &rtp =~ 'vim-fugitive'
  call fzm#Add('Find Commit', {'exec': 'Commits', 'mode': 'insert'})
  call fzm#Add('Find git File', {'exec': 'GFiles', 'mode': 'insert'})
  call fzm#Add('Git Grep', {'exec': 'GGrep', 'mode': 'insert'})
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
