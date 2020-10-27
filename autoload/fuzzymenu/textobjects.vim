let s:cpo_save = &cpo
set cpo&vim

""
" @public
" Fuzzy-select a text object (for yank,change,delete,etc)
function! fuzzymenu#textobjects#Run(operator, category) abort
  let opts = {
    \ 'source': s:TextObjectsSource(a:operator, a:category),
    \ 'sink': function('s:TextObjectsSink'),
    \ 'options': ['--ansi',
    \   '--header', ':: choose a text object'],
  \ }
  call fzf#run(fzf#wrap('fzm#TextObjects', opts, 0))
endfunction

" deprecated
function! fuzzymenu#textobjects#Curated(operator) abort
  let opts = {
    \ 'source': s:TextObjectsCuratedSource(a:operator),
    \ 'sink': function('s:TextObjectsSinkCurated', [a:operator]),
    \ 'options': '--ansi',
  \ }
  call fzf#run(fzf#wrap('fzm#TextObjects', opts, 0))
endfunction

""
" @public
" Add a text object (for yank,change,delete,etc)
function! fuzzymenu#textobjects#Add(obj, description) abort
  let s:textObjects[a:description] = a:obj
endfunction

let s:textObjects = {
 \ 'w': 'Word',
 \ 's': 'Sentence',
 \ 'p': 'Paragraph',
 \ ')': 'Round brackets (parentheses)',
 \ '}': 'Curly braces',
 \ '>': 'Angle brackets',
 \ 't': 'html/xml tags',
 \ "'": 'Single quotes',
 \ '"': 'Double quotes',
 \ '`': 'Backticks',
 \ ']': 'Block',
 \ } 

function! s:TextObjectsSource(operator, category) abort
  let textObjects = []
  for i in items(s:textObjects)
    let key = i[0]
    let description = i[1]
    let catdesc = ''
    let category = a:category
    if key == 'Line'
      " support for yy, dd, cc
      let category = a:operator
    endif
    if a:category == 'i'
      let catdesc = 'Inner '
    elseif a:category == 'a'
      let catdesc = 'Around '
    endif
    let textObject = printf("%s%s%s\t%s%s", a:operator, category, key, catdesc, description)
    call add(textObjects, textObject)
  endfor
  return textObjects
endfunction

" A dict of text objects 
" e.g. 'Line' and 'Entire buffer' (which is currently a workaround)
" TODO: many more textObjects ...
" ranges,visual,hjkl,custom text objects (e.g. vim-textobj-user)
" IMO, no need to supply an exhaustive list: people can use these examples to learn to DIY.
" NOTE: 'Line' and 'Entire buffer' are empty strings, because they're special cases - implemented differently from the rest 
"  (and this is why the descriptions are the keys)
let s:textObjectsCurated = {
      \ 'Inside word' : 'iw',
      \ 'Around word' : 'aw',
      \ 'Around sentence' : 'as',
      \ 'Around paragraph' : 'ap',
      \ 'To end of line' : '$',
      \ 'Inside round brackets (parentheses)' : 'i)',
      \ 'Inside curly braces' : 'i}',
      \ 'Inside square brackets' : 'i]',
      \ 'Inside angle brackets' : 'i>',
      \ 'Inside html/xml tag' : 'it',
      \ 'Around html/xml tag' : 'at',
      \ 'Inside single-quotes' : 'i''',
      \ 'Inside double-quotes' : 'i"',
      \ 'Inside backticks' : 'i`',
      \ 'Line' : '',
      \ 'Entire buffer' : '',
      \ 'To end of match': '//e',
      \}

function! s:TextObjectsCuratedSource(operator) abort
  let textObjects = []
  for i in items(s:textObjectsCurated)
    let key = i[0]
    let val = i[1]
    if key == 'Line'
      " support for yy, dd, cc
      let val = a:operator
    endif
    let textObject = printf("%s\t%s%s", key, a:operator, val)
    if key == 'Entire buffer'
      " TODO is there a way to do this in normal mode?
      let textObject = printf("%s\t:%%%s", key, a:operator)
    endif
    call add(textObjects, textObject)
  endfor
  return textObjects
endfunction

function! s:TextObjectsSinkCurated(operator, arg) abort
  let key = split(a:arg, "\t")[0]
  if !has_key(s:textObjects, key)
    echo printf("textobject key '%s' not found!", key)
    "return
  endif
  if key == 'Entire buffer'
    let ex = printf(":%%%s", a:operator)
    execute ex
    return
  endif
  let textObject = s:textObjects[key]
  if key == 'Line'
    " support for yy, dd, cc
    let textObject = a:operator
  endif
  call feedkeys(a:operator . textObject)
endfunction

function! s:TextObjectsSink(arg) abort
  let key = split(a:arg, "\t")[0]
  call feedkeys(key)
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
