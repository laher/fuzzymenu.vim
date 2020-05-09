let s:cpo_save = &cpo
set cpo&vim

""
" @public
" Fuzzy-select a text object (for yank,change,delete,etc)
function! fuzzymenu#normal#TextObjects(command) abort
  let opts = {
    \ 'source': s:TextObjectsSource(a:command),
    \ 'sink': function('s:TextObjectsSink', [a:command]),
    \ 'options': '--ansi',
    \ g:fuzzymenu_position: g:fuzzymenu_size,
  \ }
  call fzf#run(fzf#wrap('fzm#TextObjects', opts, 0))
endfunction

""
" @public
" Add a text object (for yank,change,delete,etc)
function! fuzzymenu#normal#AddTextObject(obj, description) abort
  let s:textObjects[a:description] = a:obj
endfunction

" TODO: many more textObjects ...
" ranges,visual,hjkl,custom text objects (e.g. vim-textobj-user)
let s:textObjects = {
      \ 'Inside word' : 'iw', 
      \ 'Around word' : 'aw', 
      \ 'To end of line' : '$', 
      \ 'Line' : '', 
      \ 'Entire buffer' : ':%', 
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
  let textObject = s:textObjects[key]
  if key == 'Line'
    " support for yy, dd, cc
    let textObject = a:command
  endif
  let ex = printf('normal! %s%s', a:command, textObject)
  if key == 'Entire buffer'
    let ex = printf(":%%%s", a:command)
  endif
  execute ex
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
