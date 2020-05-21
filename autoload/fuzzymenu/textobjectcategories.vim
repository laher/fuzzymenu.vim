let s:cpo_save = &cpo
set cpo&vim

let s:textObjectCategories = {
      \ 'i': 'Inner (text object)',
      \ 'a': 'Around (text object)',
      \ '...': 'Other (motions)',
      \ }

function! s:categories() abort
  let ret = []
  for i in items(s:textObjectCategories)
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
function! fuzzymenu#textobjectcategories#Run(operator) abort
  let opts = {
        \ 'source': s:categories(),
    \ 'sink': function('s:TextObjectCategoriesSink', [a:operator]),
    \ 'options': '--ansi',
    \ g:fuzzymenu_position : g:fuzzymenu_size,
  \ }
  call fzf#run(fzf#wrap('fzm#TextObjectCategories', opts, 0))
endfunction

function! s:TextObjectCategoriesSink(operator, arg) abort
  let key = split(a:arg, "\t")[0]
  if !has_key(s:textObjectCategories, key)
    echo printf("key '%s' not found!", key)
    return
  endif
  if key == '...'
    key = ''
  endif
  call fuzzymenu#textobjects#Full(a:operator, key)
  call fuzzymenu#InsertModeIfNvim()
endfunction
