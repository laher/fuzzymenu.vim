nnoremap <buffer> <silent> <Plug>Fzm :call fzm#Run()<cr>

function! CaseIns()
  set ignorecase
endfunction

function! CaseSens()
  set noignorecase
endfunction

if &rtp =~ 'todo.vim'
  call fzm#AddItem('Todo Prompt', 'call todo#prompt()')
  call fzm#AddItem('Todo Split', 'call todo#split()')
  call fzm#AddItem('Todo Refile', 'call todo#refile()')
endif

if &rtp =~ 'vim-lsp'
  call fzm#AddItem('Go To Definition', 'LspDefinition')
  call fzm#AddItem('Find References', 'LspReferences')
  call fzm#AddItem('Rename', 'LspRename')
endif

if &rtp =~ 'vim-fugitive'
  call fzm#AddItem('Find Commit', 'call fzm#WithInsertMode("Commits")')
  call fzm#AddItem('Find git File', 'call fzm#WithInsertMode("GFiles")')
  call fzm#AddItem('Git Grep', 'call fzm#WithInsertMode("GGrep")')
endif

if &rtp =~ 'gothx.vim'
  call fzm#AddItemFT('go', 'Go: Run', 'call gothx#run#Run()')
  call fzm#AddItemFT('go', 'Go: Test', 'call gothx#test#Test()')
  call fzm#AddItemFT('go', 'Go: Keyify', 'call gothx#keyify#Keyify()')
endif

call fzm#AddItem('No Ignore Case', 'call CaseSens()')
call fzm#AddItem('Ignore Case', 'call CaseIns()')

if !hasmapto('<Plug>Fzm', 'n')
   nmap <buffer> <Leader><Leader> <Plug>Fzm
endif

command -nargs=0 -buffer Fzm call fzm#Run()<cr>
