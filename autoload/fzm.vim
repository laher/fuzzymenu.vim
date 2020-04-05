
" let s:menu_structure = { 'go': ['go-run', 'go-install'], 'any': ['case-insensitive', 'case-sensitive'] }
" let s:menu_mappings = { 'go-run': 'gothx#run#Run','go-install': 'gothx#install#Install' , 'case-insensitive': 's:case_ins', 'case-sensitive': 's:case_sens' }

let s:menu_structure = { }
let s:menu_mappings = { }

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
  call fzf#run({'source': MenuSource(), 'sink': function('MenuSink'), 'left': '25%'})
endfunction


