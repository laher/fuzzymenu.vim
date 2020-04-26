
let s:cpo_save = &cpo
set cpo&vim

""" internal state
let s:menuItems = { }

""
" @public
" @usage {name} {def}
" Add a menu item to fuzzymenu. {name} are unique.
" {def} is a dics with a mandatory member, 'exec'
function! fuzzymenu#Add(name, def)
  if !has_key(a:def, 'exec')
    echom "definition not valid"
    return
  endif
  let s:menuItems[a:name] = a:def
endfunction

func! s:compare(i1, i2)
  return a:i1[0] == a:i2[0] ? 0 : a:i1[0] > a:i2[0] ? 1 : -1
endfunc

function! fuzzymenu#MenuSource()
  let extension = expand("%:e")
  let ret = []
  let pairs = items(s:menuItems)
  "call sort(pairs, 's:compare')
  for i in pairs 
    let name = i[0]
    let def = i[1]
    if has_key(def, 'for') 
     if extension != def['for'] 
       continue
     endif
    endif
    let help = ''
    if has_key(def, 'help') 
      let help = def['help']
    endif

    let name= printf("%s\t\t%s\t%s",
            \ s:green(name),
            \ ':'.def['exec'],
            \ s:cyan(help))
    call add(ret, name)
  endfor
  return ret
endfunction

function! fuzzymenu#MenuSink(arg)
  let key = split(a:arg, "\t")[0]
  let def = s:menuItems[key]
  if has_key(def, 'exec')
    execute def['exec']
  else
    echo "invalid key for fuzzymenu: " . key
  endif
  if has_key(def, 'after') 
   execute def['after']
  endif
endfunction

function! fuzzymenu#InsertMode()
     if has("nvim")
       call feedkeys('i')
     else
       startinsert
     endif
endfunction

""
" @public
" Invoke fuzzymenu
function! fuzzymenu#Run()
""
" @setting g:fuzzymenu_position
" Position of the fuzzymenu (using fzf positions down/up/left/right)
  let pos = get(g:, 'fuzzymenu_position', 'down')
""
" @setting g:fuzzymenu_size
" Relative size of menu
  let size = get(g:, 'fuzzymenu_size', '33%')

  let dict = {'source': fuzzymenu#MenuSource(), 'sink': function('fuzzymenu#MenuSink'), 
  \ 'options': '--ansi'}
  let dict[pos] = size
  call fzf#run(dict)

endfunction

function! s:get_color(attr, ...)
  let gui = has('termguicolors') && &termguicolors
  let fam = gui ? 'gui' : 'cterm'
  let pat = gui ? '^#[a-f0-9]\+' : '^[0-9]\+$'
  for group in a:000
    let code = synIDattr(synIDtrans(hlID(group)), a:attr, fam)
    if code =~? pat
      return code
    endif
  endfor
  return ''
endfunction

let s:ansi = {'black': 30, 'red': 31, 'green': 32, 'yellow': 33, 'blue': 34, 'magenta': 35, 'cyan': 36}

function! s:csi(color, fg)
  let prefix = a:fg ? '38;' : '48;'
  if a:color[0] == '#'
    return prefix.'2;'.join(map([a:color[1:2], a:color[3:4], a:color[5:6]], 'str2nr(v:val, 16)'), ';')
  endif
  return prefix.'5;'.a:color
endfunction

function! s:ansi(str, group, default, ...)
  let fg = s:get_color('fg', a:group)
  let bg = s:get_color('bg', a:group)
  let color = (empty(fg) ? s:ansi[a:default] : s:csi(fg, 1)) .
        \ (empty(bg) ? '' : ';'.s:csi(bg, 0))
  return printf("\x1b[%s%sm%s\x1b[m", color, a:0 ? ';1' : '', a:str)
endfunction

for s:color_name in keys(s:ansi)
  execute "function! s:".s:color_name."(str, ...)\n"
        \ "  return s:ansi(a:str, get(a:, 1, ''), '".s:color_name."')\n"
        \ "endfunction"
endfor

let &cpo = s:cpo_save
unlet s:cpo_save
