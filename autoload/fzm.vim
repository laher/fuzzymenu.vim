
" let s:menu_structure = { 'go': ['go-run', 'go-install'], 'any': ['case-insensitive', 'case-sensitive'] }
" let s:menu_mappings = { 'go-run': 'gothx#run#Run','go-install': 'gothx#install#Install' , 'case-insensitive': 's:case_ins', 'case-sensitive': 's:case_sens' }

let s:menu_structure = { }
let s:menu_mappings = { }

function! fzm#add_item_ft(ft, name, def)
  let items = [] 
  if has_key(s:menu_structure, a:ft)
    let items = s:menu_structure[a:ft]
  endif
  call add(items, a:name)
  let s:menu_structure[a:ft]= items
  let s:menu_mappings[a:name] = a:def
endfunction

function! fzm#add_item(name, def)
  call fzm#add_item_ft('any', a:name, a:def)
endfunction


function! Menu_sink(arg)
"call function(funcref(
 echo s:menu_mappings[a:arg]
 execute s:menu_mappings[a:arg]
endfunction

function! Menu_source()
  let extension = expand("%:e")
  let ret = s:menu_structure['any']
  let others = get(s:menu_structure, extension, [])
  ret += others
  return ret
endfunction

function! fzm#run()
  call fzf#run({'source': Menu_source(), 'sink': function('Menu_sink'), 'left': '25%'})
endfunction


