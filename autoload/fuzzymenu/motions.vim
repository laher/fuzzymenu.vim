let s:cpo_save = &cpo
set cpo&vim

let s:motions = {
      \ 'w': 'word',
      \ 'W': 'WORD',
      \ 'Line': 'Word',
      \ }

function! fuzzymenu#motions#Source(operator) abort
  let textObjects = []
  for i in items(s:motions)
    let key = i[0]
    let val = i[1]
    if key == 'Line'
      " support for yy, dd, cc
      let val = a:operator
    endif
    let textObject = printf("%s\t%s%s", key, a:operator, val)
    call add(textObjects, textObject)
  endfor
  return textObjects
endfunction

