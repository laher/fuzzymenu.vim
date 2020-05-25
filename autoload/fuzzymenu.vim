
let s:cpo_save = &cpo
set cpo&vim

""" Internal state
" structure: []
" each item should be {'items': [{'key':'x', 'exec':'y'}], 'metadata': {}}
let s:menuItems = []

""
" @public
" @usage {items} {baseDef}
" Add several menu items to fuzzymenu. {items} is a dict of names and defs.
" {baseDef} is a dict to combine with each item
" (see Add()).
" {baseDef} is a dict with common members
function! fuzzymenu#AddAll(items, metadata) abort
  for i in items(a:items)
    if !s:validate(i[0], i[1])
      echom printf("definition %s not valid", i[0])
      return
    endif
  endfor
  if !s:valMetadata(a:metadata)
    echom "definition metadata not valid"
    return
  endif
  call add(s:menuItems, {'items': a:items, 'metadata': a:metadata})
  " let kvPairs = items(a:items)
  " for i in kvPairs
  "   let name = i[0]
  "   let v = i[1]
  "   let def = copy(a:baseDef)
  "   for j in items(v)
  "     let def[j[0]] = j[1]
  "   endfor
  "   call fuzzymenu#Add(name, def)
  " endfor
endfunction

let s:allowedDefKeys = ['exec', 'normal', 'hint']
let s:requiredDefKeys = ['exec', 'normal']
function! s:validate(name, def) abort
  let ks = keys(a:def)
  let found = 0
  for i in s:requiredDefKeys
    if index(ks, i) >= 0
      let found += 1
    endif
  endfor
  if found != 1
    return 0
  endif
  for i in items(a:def)
    if (index(s:allowedDefKeys, i[0]) < 0)
     return 0 
    endif
  endfor
  return 1
endfunction

let s:allowedMetadataKeys = ['modes', 'after', 'tags', 'for', 'help']
function! s:valMetadata(def) abort
  for i in items(a:def)
    if (index(s:allowedMetadataKeys, i[0]) < 0)
     return 0 
    endif
  endfor
  return 1
endfunction

""
" @public
" @usage {name} {def}
" Add a menu item to fuzzymenu. {name} are unique.
" {def} is a dict with a mandatory member, 'exec'
function! fuzzymenu#Add(name, def, ...) abort
  let metadata = {}
  if a:0
    let metadata = a:1
  endif
  if !s:validate(a:name, a:def) 
    echom printf("definition %s not valid", a:name)
    return
  endif
  if !s:valMetadata(metadata)
    echom printf("definition %s metadata not valid", a:name)
    return
  endif
  call add(s:menuItems, {'items':{a:name : a:def}, 'metadata': metadata})
  "let s:menuItemsSource[s:key(a:name, a:def)] = a:def
endfunction

function fuzzymenu#Get(name) abort
  for g in s:menuItems
    let gMetadata = g['metadata']
    let gItems = items(g['items'])
    for i in gItems
      let k = i[0]
      let def = i[1]
      if key == s:key(k, d)
        return def
      endif
    endfor
  endfor
endfunction

function s:key(name, def)
  let t = ''
  if has_key(a:def, 'tags')
    let t = toupper('[' . join(a:def['tags'], ',') . ']')
    let t = ' ' . t
  endif
  return printf('%s%s', a:name, t)
endfunction

function s:colorizeTags(key)
    let parts = split(a:key, "[")
    if len(parts)>1
      let parts[1] = s:color('cyan', parts[1])
    endif
    return join(parts, "[")
endfunction

func! s:compare(i1, i2)
  return a:i1[0] == a:i2[0] ? 0 : a:i1[0] > a:i2[0] ? 1 : -1
endfunc

function! s:ShouldSkip(def, extension) abort
    if has_key(a:def, 'for')
      let conditions = a:def['for']
      if type(conditions) != type({})
        " support for original 'for' as a filetype string. Deprecated.
        let conditions = {'ft': conditions}
      endif
      if has_key(conditions, 'ft')
        if a:extension != conditions['ft']
          return 1
        endif
      endif
      " comparing at runtime should allow us to handle conditional plugin
      " loading
      if has_key(conditions, 'exists')
        if !exists(conditions['exists'])
          return 1
        endif
      endif
    endif
    return 0
endfunction

function! s:MenuSource(currentMode) abort
  let extension = expand("%:e")
  let ret = []
  let rows = []
  " let pairs = items(s:menuItemsSource)
  " call sort(pairs, 's:compare')
  let width= winwidth(0) - (max([len(line('$')), &numberwidth-1]) + 1)
  " for i in pairs
  for g in s:menuItems
    let gMetadata = g['metadata']
    let gItems = items(g['items'])
    if s:ShouldSkip(gMetadata, extension)
      continue
    endif
    for i in gItems
      let k = i[0]
      let def = i[1]
      let help = ''
      if has_key(def, 'help')
        let help = def['help']
      endif
      if has_key(def, 'modes')
        let modes = def['modes']
        if  modes !~ a:currentMode
          " doesn't apply
          continue
        endif
      endif

      if has_key(def, 'exec')
        let cmd = has_key(def, 'hint') ? def['hint'] : def['exec']
        if cmd =~ '^call '
          let cmd = substitute(cmd, '^call ', s:color('cyan', ':call '), '')
        else
          let cmd = s:color('cyan', ':') . cmd
        endif
      elseif has_key(def, 'normal')
        let cmd = has_key(def, 'hint') ? def['hint'] : def['normal']
        let cmd = s:color('cyan', 'normal: ') . cmd
      else
        " TODO: print error
        return []
      endif

      let mx = 0
      let row = [k, cmd]
      call add(rows, row)
    endfor
  endfor

  "" handle whitespace indentation
  for i in rows
    let gap=width-len(i[0])-25
    if gap<6
      let gap=6
    endif
    let l = repeat(' ', gap-5)
    if l == ''
      let l = ' '
    endif
    let line = printf("%s".l."\t%s", s:colorizeTags(i[0]), i[1])
    call add(ret, line)
  endfor
  return ret
endfunction

function! s:MenuSink(mode, arg) abort
  let key = trim(split(a:arg, "\t")[0])
  let found = 0
  let def = {}
  let gMeta = {}
  for g in s:menuItems
    let gItems = g['items']
    for i in items(gItems)
      let k = i[0]
      let d = i[1]
      if key == s:key(k, d)
        let found = 1
        let def = d
        let gMeta = g['metadata']
        break
      endif
    endfor
    if found == 1
      break
    endif
  endfor
  if !found
  "if !has_key(s:menuItemsSource, key)
    echo printf("key '%s' not found!", key)
    "TODO: error how?
  endif
  "let def = s:menuItemsSource[key]
  if has_key(def, 'exec')
    if a:mode == 'v'
      " execute on selected range
      " TODO: only support range when it makes sense to? ... or should we just allow it? Someone can always just use normal-mode if it fails
      execute "'<,'>" . def['exec']
    else
      execute def['exec']
    endif
  elseif has_key(def, 'normal')
    " TODO: check mode?
    call feedkeys(def['normal'])
  else
    echo "invalid key for fuzzymenu: " . key
  endif
  if has_key(def, 'after')
   let after = def['after']
   execute after
  endif
  if has_key(gMeta, 'after')
   let after = gMeta['after']
   execute after
  endif
endfunction

function! fuzzymenu#InsertModeIfNvim() abort
     if has("nvim")
       call feedkeys('i')
     endif
endfunction

function! fuzzymenu#InsertMode() abort
     if has("nvim")
       call feedkeys('i')
     else
       startinsert
     endif
endfunction

" TODO find a simpler way to extract word during fzf-sink
" (I don't wanna create a wrapper func each time)
function! fuzzymenu#GitFileUnderCursor()
 let query = expand("<cword>")
 let opts = ''
 if query != ''
   let opts = '-q ' . query
 endif
 call fzf#vim#gitfiles('', fzf#wrap({
      \ 'options': opts,
      \ }), 0)
endfunction

function! fuzzymenu#GitGrepUnderCursor()
 let opt = expand("<cword>")
 call fzf#vim#grep(
\   'git grep --line-number '.shellescape(opt), 0,
\   fzf#vim#with_preview({ 'dir': systemlist('git rev-parse --show-toplevel')[0] }), 0)
endfunction

""
" @public
" Invoke fuzzymenu
function! fuzzymenu#Run(params) abort range
  let mode = 'n'
  if has_key(a:params, 'visual')
    if a:params['visual'] == 1
      let mode = 'v'
    endif
  endif

  let opts = {
    \ 'source': s:MenuSource(mode),
    \ 'sink': function('s:MenuSink', [mode]),
    \ 'options': ['--ansi', '--header', ':: Fuzzymenu - fuzzy select an item. _Try "Operator"_']}
  let opts[g:fuzzymenu_position] = g:fuzzymenu_size
  let fullscreen = 0
  if has_key(a:params, 'fullscreen')
    let fullscreen = a:params['fullscreen']
  endif
  call fzf#run(fzf#wrap('fuzzymenu', opts, fullscreen))
endfunction

function! s:get_color(attr, ...) abort
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

function! s:csi(color, fg) abort
  let prefix = a:fg ? '38;' : '48;'
  if a:color[0] == '#'
    return prefix.'2;'.join(map([a:color[1:2], a:color[3:4], a:color[5:6]], 'str2nr(v:val, 16)'), ';')
  endif
  return prefix.'5;'.a:color
endfunction

function! s:ansi(str, group, default, ...) abort
  let fg = s:get_color('fg', a:group)
  let bg = s:get_color('bg', a:group)
  let color = (empty(fg) ? s:ansi[a:default] : s:csi(fg, 1)) .
        \ (empty(bg) ? '' : ';'.s:csi(bg, 0))
  return printf("\x1b[%s%sm%s\x1b[m", color, a:0 ? ';1' : '', a:str)
endfunction

function! s:color(color_name, str, ...) abort
  return s:ansi(a:str, get(a:, 1, ''), a:color_name)
endfunc

let &cpo = s:cpo_save
unlet s:cpo_save
