nnoremap <buffer> <silent> <Plug>Fzm :call fuzzymenu#Run()<cr>

let auto_mappings = get(g:, 'fuzzymenu_auto_mappings', 1)
  
if auto_mappings
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
  call fuzzymenu#Add('FZF: Key mappings', {'exec': 'Maps', 'mode': 'insert', 'help': 'vim key mappings'})
  call fuzzymenu#Add('FZF: Ex commands', {'exec': 'Commands', 'mode': 'insert'})
  call fuzzymenu#Add('FZF: History', {'exec': 'History', 'mode': 'insert'})
  call fuzzymenu#Add('FZF: Command history', {'exec': 'History:', 'mode': 'insert'})
  call fuzzymenu#Add('FZF: Search history', {'exec': 'History/', 'mode': 'insert'})
  call fuzzymenu#Add('FZF: Help tags', {'exec': 'Helptags', 'mode': 'insert'})
  call fuzzymenu#Add('FZF: Lines in loaded buffers', {'exec': 'Lines', 'mode': 'insert'})
  call fuzzymenu#Add('FZF: Lines in current buffer', {'exec': 'BLines', 'mode': 'insert'})

  if !hasmapto('<Plug>Fzm', 'n')
     nmap <buffer> <Leader><Leader> <Plug>Fzm
  endif
endif

command -nargs=0 -buffer Fzm call fuzzymenu#Run()<cr>
