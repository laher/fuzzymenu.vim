nnoremap <buffer> <silent> <Plug>Fzm :call fzm#run()<cr>

function! CaseIns()
  set ignorecase
endfunction

function! CaseSens()
  set noignorecase
endfunction

if &rtp =~ 'todo.vim'
  call fzm#add_item('Todo Prompt', 'call todo#prompt()')
  call fzm#add_item('Todo Split', 'call todo#split()')
endif

if &rtp =~ 'vim-lsp'
  call fzm#add_item('Go To Definition', 'LspDefinition')
  call fzm#add_item('Find References', 'LspReferences')
  call fzm#add_item('Rename', 'LspRename')
endif

call fzm#add_item('Git Grep', "GGrep")
call fzm#add_item('No Ignore Case', 'call CaseSens()')
call fzm#add_item('Ignore Case', 'call CaseIns()')


if !hasmapto('<Plug>Fzm', 'n')
   nmap <buffer> <Leader><Leader> <Plug>Fzm
endif

command -nargs=0 -buffer Fzm call fzm#run()<cr>
