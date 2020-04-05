
""" internal state
let s:menuItems = { }

function! fzm#Add(name, def)
  if !has_key(a:def, 'exec')
    echom "definition not valid"
    return
  endif
  let s:menuItems[a:name] = a:def
endfunction

function! fzm#MenuSource()
  let extension = expand("%:e")
  let ret = []
  for i in items(s:menuItems)
    let name = i[0]
    let def = i[1]
    if has_key(def, 'for') 
     if extension != def['for'] 
       continue
     endif
    endif
    call add(ret, name)
  endfor
  return ret
endfunction

function! fzm#MenuSink(arg)
  let def = s:menuItems[a:arg]
  if has_key(def, 'exec')
    execute def['exec']
  else
    echom "invalid arg " . a:arg
  endif
  if has_key(def, 'mode') 
   if def['mode'] == 'insert'
     if has("nvim")
       call feedkeys('i')
     else
       startinsert
     endif
   endif
  endif
endfunction

function! fzm#Run()
  "call fzf#run({'source': MenuSource(), 'sink': function('MenuSink'), 'left': '25%'})
  call fzf#run({'source': fzm#MenuSource(), 'sink': function('fzm#MenuSink'), 'left': '25%'})
endfunction


