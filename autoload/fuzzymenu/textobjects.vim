let s:cpo_save = &cpo
set cpo&vim

""
" @public
" Fuzzy-select a text object (for yank,change,delete,etc)
function! fuzzymenu#textobjects#Run(command) abort
  let opts = {
    \ 'source': s:TextObjectsSource(a:command),
    \ 'sink': function('s:TextObjectsSink', [a:command]),
    \ 'options': '--ansi',
    \ g:fuzzymenu_position : g:fuzzymenu_size,
  \ }
  call fzf#run(fzf#wrap('fzm#TextObjects', opts, 0))
endfunction

""
" @public
" Add a text object (for yank,change,delete,etc)
function! fuzzymenu#textobjects#Add(obj, description) abort
  let s:textObjects[a:description] = a:obj
endfunction

" A dict of text objects 
" e.g. 'Line' and 'Entire buffer' (which is currently a workaround)
" TODO: many more textObjects ...
" ranges,visual,hjkl,custom text objects (e.g. vim-textobj-user)
" IMO, no need to supply an exhaustive list: people can use these examples to learn to DIY.
" NOTE: 'Line' and 'Entire buffer' are empty strings, because they're special cases - implemented differently from the rest 
"  (and this is why the descriptions are the keys)
let s:textObjects = {
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

function! s:TextObjectsSource(command) abort
  let textObjects = []
  for i in items(s:textObjects)
    let key = i[0]
    let val = i[1]
    if key == 'Line'
      " support for yy, dd, cc
      let val = a:command
    endif
    let textObject = printf("%s\t%s%s", key, a:command, val)
    if key == 'Entire buffer'
      " TODO is there a way to do this in normal mode?
      let textObject = printf("%s\t:%%%s", key, a:command)
    endif
    call add(textObjects, textObject)
  endfor
  return textObjects
endfunction

function! s:TextObjectsSink(command, arg) abort
  let key = split(a:arg, "\t")[0]
  if !has_key(s:textObjects, key)
    echo printf("key '%s' not found!", key)
    "return
  endif
  if key == 'Entire buffer'
    let ex = printf(":%%%s", a:command)
    execute ex
    return
  endif
  let textObject = s:textObjects[key]
  if key == 'Line'
    " support for yy, dd, cc
    let textObject = a:command
  endif
  call feedkeys(a:command . textObject)
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
