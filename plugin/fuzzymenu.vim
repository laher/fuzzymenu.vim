if exists('g:fuzzymenu_loaded')
    finish
endif
let g:fuzzymenu_loaded = 1

" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

""
" @section Introduction, intro
" {fuzzymenu}{1} is a fuzzy-finder menu for vim, built on top of {fzf}{2}. Discover vim features easily, just invoke fuzzymenu and start typing. See the fuzzymenu.vim README for more background.
"
" {1} https://github.com/laher/fuzzymenu.vim
" {2} https://github.com/junegunn/fzf
"
" See also, |fzf|

""
" @setting fuzzymenu_position
" Position of the fuzzymenu (using fzf positions down/up/left/right)
let g:fuzzymenu_position = get(g:, 'fuzzymenu_position', 'down')

""
" @setting fuzzymenu_size
" Relative size of menu (default is '33%')
let g:fuzzymenu_size = get(g:, 'fuzzymenu_size', '33%')

let fvc = '~/.vimrc.fuzzymenu'

""
" @setting fuzzymenu_vim_config
" config file used for dynamically updating vim settings 
" Recommend using a secondary file, then including it from .vimrc
let g:fuzzymenu_vim_config = get(g:, 'fuzzymenu_vim_config', fvc)

if filereadable(expand(g:fuzzymenu_vim_config))
    """ re-interpret fuzzymenu vim config:
    exec 'source ' . expand(g:fuzzymenu_vim_config)
endif

" @setting fuzzymenu_auto_write
" auto write config 
" Recommend using a secondary file, then including it from .vimrc
let g:fuzzymenu_vim_config_auto_write = get(g:, 'fuzzymenu_vim_config_auto_write', 1)

""
" Open fuzzymenu in normal mode.
" TODO: this is super slow when mapped... why?!
nnoremap <silent> <Plug>Fzm :call fuzzymenu#Run({})<cr>

""
" Open fuzzymenu's guided operators menu.
" TODO: this is super slow when mapped... why?!
nnoremap <silent> <Plug>FzmOps :call fuzzymenu#operators#OperatorCommands()<cr>

""
" Open fuzzymenu in normal mode.
" TODO: this is super slow when mapped... why?!
xnoremap <silent> <Plug>FzmVisual :call fuzzymenu#RunVisual()<cr>

""
" @setting g:fuzzymenu_auto_add
" Automatically add menu items. Note: I'll break these up in future into
" several categories
let g:fuzzymenu_auto_add = get(g:, 'fuzzymenu_auto_add', 1)

let fzfPrefix = get(g:, 'fzf_command_prefix', '')

if g:fuzzymenu_auto_add

" vim-lsp mappings
call fuzzymenu#AddAll({
      \ 'Go to definition': {'exec': 'LspDefinition'},
      \ 'Show info': {'exec': 'LspHover'},
      \ 'Install language server': {'exec': 'LspInstallServer'},
      \ 'Find references': {'exec': 'LspReferences'},
      \ 'Rename': {'exec': 'LspRename'},
      \ 'Organize imports': {'exec': 'LspCodeActionSync source.organizeImports'},
      \ 'Go to implementation': {'exec': 'LspImplementation'},
      \ 'Next error': {'exec': 'LspNextError'},
    \ },
    \ {'tags': ['lsp', 'vim-lsp'],
    \ 'for': {'exists': 'g:lsp_loaded'}})

" fuzzymenu
" git mappings
call fuzzymenu#AddAll({
      \ 'Find commit': {'exec': fzfPrefix.'Commits'},
      \ 'Find commit in current buffer': {'exec': fzfPrefix.'BCommits'},
      \ 'Open file': {'exec': fzfPrefix.'GFiles'},
      \ 'Find in files': {'exec': 'GGrep'},
      \ 'Find word under cursor as filename': {'exec': 'call fuzzymenu#GitFileUnderCursor()'},
      \ 'Find word under cursor in files': {'exec': 'call fuzzymenu#GitGrepUnderCursor()'},
    \ },
    \ {'after': 'call fuzzymenu#InsertModeIfNvim()', 'tags': ['git', 'fzf'],
    \ 'for': {'exists': 'g:loaded_fugitive'}})
" this one is also tagged github
call fuzzymenu#Add('Browse to file/selection', {'exec': 'GBrowse'}, { 
    \ 'after': 'call fuzzymenu#InsertModeIfNvim()', 'tags': ['git', 'github', 'visual'],
    \ 'for': {'exists': 'g:loaded_fugitive'}})


" basic options
call fuzzymenu#Add('Set case-sensitive searches', {'exec': 'set noignorecase'})
call fuzzymenu#Add('Set case-insensitive searches', {'exec': 'set ignorecase'})
call fuzzymenu#Add('Hide line numbers', {'exec': 'set nonumber'})
call fuzzymenu#Add('Show line numbers', {'exec': 'set number'})
call fuzzymenu#Add('Hide whitespace characters', {'exec': 'set nolist'})
call fuzzymenu#Add('Show whitespace characters', {'exec': 'set list'})
call fuzzymenu#Add('Undo', {'normal': 'u'})
call fuzzymenu#Add('Redo', {'normal': "\<c-r>"})
call fuzzymenu#Add('Quit (exit) all', {'exec': 'qa'})
call fuzzymenu#Add('Quit (exit) all without saving', {'exec': 'qa!'})
call fuzzymenu#Add('Write (save) and quit (exit) all', {'exec': 'wqa'})
call fuzzymenu#Add('Write (save) current buffer', {'exec': 'w'})
call fuzzymenu#Add('Write (save) all', {'exec': 'wa'})

" common editor features
call fuzzymenu#Add('New buffer', {'exec': 'new'})
call fuzzymenu#Add('Delete buffer (close file)', {'exec': 'bd'})
call fuzzymenu#Add('Delete buffer (close file) WITHOUT saving', {'exec': 'bd!'})
call fuzzymenu#Add('Vertical split', {'exec': 'vs'})
call fuzzymenu#Add('Horizontal split', {'exec': 'sp'})
call fuzzymenu#Add('Select all', {'normal': 'ggVG'})
call fuzzymenu#Add('Find word under cursor', {'normal': '*'})
call fuzzymenu#Add('Next match', {'normal': 'n'})
call fuzzymenu#Add('Previous match', {'normal': 'N'})
call fuzzymenu#Add('Repeat (last normal mode operation)', {'normal': '.'})
call fuzzymenu#Add('Repeat (last :command)', {'normal': '@:'})
call fuzzymenu#Add('Open file under cursor', {'normal': 'gf'})
call fuzzymenu#Add('Browse to link under cursor', {'normal': 'gx'})

" normal mode for incomplete functions
call fuzzymenu#Add('Find', {'normal': '/'})
call fuzzymenu#Add('Next match', {'normal': 'n'})
call fuzzymenu#Add('Previous match', {'normal': 'N'})
call fuzzymenu#Add('Replace next match', {'normal': ':s//'})
call fuzzymenu#Add('Replace in file', {'normal': ':%s//'})
call fuzzymenu#Add('Replace in open buffers', {'normal': ':bufdo :%s//'})

" normal mode operators (For text objects) 

let ops = {}
for i in items(fuzzymenu#operators#Get())
    let name = i[1]
    let op = i[0]
    let ops[name] = { 'exec': 'FzmOp '.op }
endfor
call fuzzymenu#AddAll(ops,
    \ {'after': 'call fuzzymenu#InsertModeIfNvim()', 'tags': ['normal','fzf']})

let ops = {}
for i in items(fuzzymenu#operators#Get())
    let name = i[1]
    let op = i[0]
    "" remove 'g' prefix from uppercase/lowercase/format/...
    let op = substitute(op, '^g', '', '')
    let ops[name] = { 'visual': op }
endfor

call fuzzymenu#AddAll(ops,
    \ {'tags': ['visual','fzf']})

call fuzzymenu#Add('Operators (text objects and motions)', {
      \ 'exec': 'FzmOps'}, {
      \ 'after': 'call fuzzymenu#InsertModeIfNvim()', 
      \ 'tags': ['normal','fzm']
      \})

call fuzzymenu#AddAll({
      \'Apply setting (persist)': { 'exec': 'call fuzzymenu#vimconfig#ApplySetting(1)'}, 
      \'Apply setting (temporary)': { 'exec': 'call fuzzymenu#vimconfig#ApplySetting(0)'}, 
      \'Create a key mapping (persist)': { 'exec': 'call fuzzymenu#vimconfig#MapKey({})' },
      \ },
      \ { 'after': 'call fuzzymenu#InsertModeIfNvim()', 'tags': ['normal','fzm']})

call fuzzymenu#Add('Put (paste)', {'normal': 'p'}, {'tags': ['normal']})

""" fzf tools
call fuzzymenu#AddAll({
      \ 'Key mappings': {'exec': fzfPrefix.'Maps'},
      \ 'Buffers (open files)': {'exec': fzfPrefix.'Buffers'},
      \ 'Vim commands': {'exec': fzfPrefix.'Commands'},
      \ 'Open recent file': {'exec': fzfPrefix.'History'},
      \ 'Recent commands': {'exec': fzfPrefix.'History:'},
      \ 'Recent searches': {'exec': fzfPrefix.'History/'},
      \ 'Help': {'exec': fzfPrefix.'Helptags'},
      \ 'Find in open buffers (files)': {'exec': fzfPrefix.'Lines'},
      \ 'Find (in current buffer)': {'exec': fzfPrefix.'BLines'},
      \ 'Open file': {'exec': fzfPrefix.'Files'},
    \ },
    \ {'after': 'call fuzzymenu#InsertModeIfNvim()', 'tags': ['fzf']})

" vim-go. (see also gothx.vim)
" NOTE: vim-go mappings won't load when loading plugins on demand (this is not a 'go'
" file so vim-go may not be loaded). Considering options ...
call fuzzymenu#AddAll({
        \ 'Run': {'exec': 'GoRun'},
        \ 'Test': {'exec': 'GoTest'},
        \ 'Keyify (specify keys in structs)': {'exec': 'GoKeyify'},
        \ 'IfErr': {'exec': 'GoIfErr'},
        \ 'Fill Struct': {'exec': 'GoFillStruct'},
        \ 'Play (launch in browser)': {'exec': 'GoPlay'},
        \ 'Alternate to/from test file': {'exec': 'GoAlternate'},
      \ },
      \ {'for': {'ft': 'go', 'exists': 'g:go_loaded_install'}, 'tags':['go','vim-go']})

endif

" TODO: make these optional?
" let g:fuzzymenu_map_keys = get(g:, 'fuzzymenu_map_keys', 0)
" if g:fuzzymenu_map_keys
"
" @section Mappings, mappings
" There are one normal-mode mapping, "<Leader><Leader>" to invoke fuzzymenu
" if !hasmapto('<Plug>Fzm', 'n')
"    nmap <Leader><Leader> <Plug>Fzm
" endif

" if !hasmapto('<Plug>Fzm', 'v')
"    xmap <Leader><Leader> <Plug>FzmVisual
" endif

" endif

""
" @section Commands, commands
" There is a single command, @command(Fzm), to invoke fuzzymenu.

""
" Fzm invokes fuzzymenu
command! -bang -nargs=0 Fzm call fuzzymenu#Run({'fullscreen': <bang>0})

""
" FzmOps launches a multi-step fzm sequence of operators and text-objects/motions
command! -bang -nargs=0 FzmOps call fuzzymenu#operators#OperatorCommands()

""
" FzmOp {operator} launches a multi-step fzm sequence of text-objects/motions
command! -bang -nargs=1 FzmOp call fuzzymenu#operatorpending#Run(<q-args>)

""
" FzmMapKey launches a multi-step fzm sequence to map a key into your vim config
command! -bang -nargs=0 FzmMapKey call fuzzymenu#vimconfig#MapKey({})

""
" GGrep finds a file using git as a base dir
" GGrep runs fzf#vim#grep with git-grep. This is recommended in fzf docs
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({ 'dir': systemlist('git rev-parse --show-toplevel')[0] }), <bang>0)


" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save
