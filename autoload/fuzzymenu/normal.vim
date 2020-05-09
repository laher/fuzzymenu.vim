let s:cpo_save = &cpo
set cpo&vim

function! fuzzymenu#normal#Motions(command) abort
  let opts = {
    \ 'source': s:MotionsSource(a:command),
    \ 'sink': function('s:MotionsSink', [a:command]),
    \ 'options': '--ansi',
    \ g:fuzzymenu_position: g:fuzzymenu_size,
  \ }
  call fzf#run(fzf#wrap('fuzzymenu#normal#Motions', opts, 0))
endfunction

let s:motions = {
      \ 'Inside word' : 'iw', 
      \ 'Around word' : 'aw', 
      \ 'To end of line' : '$', 
      \ 'Line' : '', 
      \ 'Entire buffer' : '%', 
      \}

function! s:MotionsSource(command) abort
  let motions = []
  for i in items(s:motions)
    let key = i[0]
    let val = i[1]
    if key == 'Line'
      " support for yy, dd, cc
      let val = a:command
    endif
    let motion = printf("%s\t%s%s", key, a:command, val)
    if key == 'Entire buffer'
      let motion = printf("%s\t%%%s", key, a:command)
    endif
    call add(motions, motion)
  endfor
  return motions
endfunction

function! s:MotionsSink(command, arg) abort
  let key = split(a:arg, "\t")[0]
  if !has_key(s:motions, key)
    echo printf("key '%s' not found!", key)
    "return
  endif
  let motion = s:motions[key]
  if key == 'Line'
    " support for yy, dd, cc
    let motion = a:command
  endif
  let ex = printf('normal! %s%s', a:command, motion)
  if key == 'Entire buffer'
    let ex = printf("normal! %%%s", a:command)
  endif
  execute ex
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
