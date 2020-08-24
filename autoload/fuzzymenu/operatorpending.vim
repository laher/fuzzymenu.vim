let s:cpo_save = &cpo
set cpo&vim

let s:operatorPending = {
      \ 'i': 'Inner (text object)',
      \ 'a': 'Around (text object)',
      \ '...': 'Other (motions)',
      \ 'n...': 'Multiplier (text objects or motions)',
      \ }

function! s:categories() abort
  let ret = []
  for i in items(s:operatorPending)
    let key = i[0]
    let val = i[1]
    let item = printf("%s\t%s", key, val)
    call add(ret, item)
  endfor
  return ret
endfunction

""
" @public
" Fuzzy-select a text object (for yank,change,delete,etc)
function! fuzzymenu#operatorpending#Run(operator) abort
  let opts = {
        \ 'source': s:categories(),
    \ 'sink': function('s:OperatorPendingSink', [a:operator]),
    \ 'options': ['--ansi',
    \   '--header', ':: choose a text object, motion, or multiplier'],
    \ g:fuzzymenu_position : g:fuzzymenu_size,
  \ }
  call fzf#run(fzf#wrap('fzm#OperatorPending', opts, 0))
endfunction

function! s:OperatorPendingSink(operator, arg) abort
  let key = split(a:arg, "\t")[0]
  if !has_key(s:operatorPending, key)
    echo printf("operator-pending key '%s' not found!", key)
    return
  endif
  if key == 'n...' || key == '...'
    let multiplier = ''
    if key == 'n...'
      let multiplier = input('Enter multiplier (or leave blank for a single item):')
    endif
    call fuzzymenu#motions#Run(a:operator, multiplier)
  else
    call fuzzymenu#textobjects#Run(a:operator, key)
  endif
  call fuzzymenu#InsertModeIfNvim()
endfunction
