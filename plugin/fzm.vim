nnoremap <buffer> <silent> <Plug>Fzm :call fzm#Run()<cr>

let auto_mappings = get(g:, 'fuzzy_menu_auto_mappings', 1)
  
if auto_mappings
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
  call fzm#Add('Set case-sensitive searches', {'exec': 'set noignorecase'})
  call fzm#Add('Set case-insensitive searches', {'exec': 'set ignorecase'})
  call fzm#Add('Hide line numbers', {'exec': 'set nonumber'})
  call fzm#Add('Show line numbers', {'exec': 'set number'})
  call fzm#Add('Hide whitespace characters', {'exec': 'set nolist'})
  call fzm#Add('Show whitespace characters', {'exec': 'set list'})

  """ fzf tools
  call fzm#Add('FZF: Key mappings', {'exec': 'Maps', 'mode': 'insert', 'help': 'vim key mappings'})
  call fzm#Add('FZF: Ex commands', {'exec': 'Commands', 'mode': 'insert'})
  call fzm#Add('FZF: History', {'exec': 'History', 'mode': 'insert'})
  call fzm#Add('FZF: Command history', {'exec': 'History:', 'mode': 'insert'})
  call fzm#Add('FZF: Search history', {'exec': 'History/', 'mode': 'insert'})
  call fzm#Add('FZF: Help tags', {'exec': 'Helptags', 'mode': 'insert'})
  call fzm#Add('FZF: Lines in loaded buffers', {'exec': 'Lines', 'mode': 'insert'})
  call fzm#Add('FZF: Lines in current buffer', {'exec': 'BLines', 'mode': 'insert'})

  if !hasmapto('<Plug>Fzm', 'n')
     nmap <buffer> <Leader><Leader> <Plug>Fzm
  endif
endif

command -nargs=0 -buffer Fzm call fzm#Run()<cr>
