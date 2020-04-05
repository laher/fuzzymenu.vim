
" let s:menu_structure = { 'go': ['go-run', 'go-install'], 'any': ['case-insensitive', 'case-sensitive'] }
" let s:menu_mappings = { 'go-run': 'gothx#run#Run','go-install': 'gothx#install#Install' , 'case-insensitive': 's:case_ins', 'case-sensitive': 's:case_sens' }

let s:menu_structure = { }
let s:menu_mappings = { }

let s:menuItems = { }

function! fzm#Add(name, def)
  if !has_key(a:def, 'command') && !has_key(a:def, 'exec')
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
  echo ret
  return ret
endfunction

function! fzm#MenuSink(arg)
" [a:name] = a:def
" call function(funcref(
" echo s:menu_mappings[a:arg]
" execute s:menu_mappings[a:arg]
  let def = s:menuItems[a:arg]
  if has_key(def, 'command') 
    execute def['command']
  elseif has_key(def, 'exec')
    execute def['exec']
  else
    echom "invalid arg " . a:arg
  endif
  if has_key(def, 'insert_mode') 
   if has("nvim")
     call feedkeys('i')
   else
     startinsert
   endif
  endif
endfunction

function! fzm#AddItemFT(ft, name, def)
  let items = [] 
  if has_key(s:menu_structure, a:ft)
    let items = s:menu_structure[a:ft]
  endif
  call add(items, a:name)
  let s:menu_structure[a:ft]= items
  let s:menu_mappings[a:name] = a:def
endfunction

function! fzm#AddItem(name, def)
  call fzm#AddItemFT('any', a:name, a:def)
endfunction

function! fzm#WithInsertMode(def)
   execute a:def
   if has("nvim")
    call feedkeys('i')
   else
     startinsert
   endif
endfunction

function! MenuSink(arg)
"call function(funcref(
 echo s:menu_mappings[a:arg]
 execute s:menu_mappings[a:arg]
endfunction

function! MenuSource()
  let extension = expand("%:e")
  let ret = s:menu_structure['any']
  let others = get(s:menu_structure, extension, [])
  ret += others
  return ret
endfunction

function! fzm#Run()
  "call fzf#run({'source': MenuSource(), 'sink': function('MenuSink'), 'left': '25%'})
  call fzf#run({'source': fzm#MenuSource(), 'sink': function('fzm#MenuSink'), 'left': '25%'})
endfunction


