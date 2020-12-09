
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
endfunction

let s:allowedDefKeys = ['exec', 'normal', 'hint', 'visual']
let s:requiredDefKeys = ['exec', 'normal', 'visual']
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
endfunction

function! s:merge(defaults, override) abort
  return extend(copy(a:defaults), a:override)
endfunction

function! fuzzymenu#Trim(input_string) abort
  if has('nvim') || v:versionlong >= 8001630
    return trim(a:input_string)
  else
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
  endif 
endfunction

function fuzzymenu#Get(name) abort
  let key = fuzzymenu#Trim(split(a:name, "\t")[0])
  for g in s:menuItems
    let gMetadata = items(g['metadata'])
    let gItems = items(g['items'])
    for i in gItems
      let k = i[0]
      let d = i[1]
      let def = s:merge(g['metadata'], d)
      if key == s:key(k, def)
        return def
      endif
    endfor
  endfor
  echom printf("definition %s not found", a:name)
  "" error here?
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

function! s:ShouldSkip(def, extension, tags) abort
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
    if len(a:tags)
      "" skip unless this item has a matching tag
      if has_key(a:def, 'tags')
        for i in a:def['tags']
          for j in a:tags
            if i == j
              return 0
            endif
          endfor
        endfor
      endif
      return 1
    endif
    return 0
endfunction

""
" @public
" Main source of menu items. Combine with a Sink
function! fuzzymenu#MainSource(options) abort
  let currentMode = has_key(a:options, 'mode') ?  a:options['mode'] : 'n'
  let extension = has_key(a:options, 'filetype') ? a:options['filetype'] : ''
  let tags = has_key(a:options, 'tags') ? a:options['tags'] : []
  let ret = []
  let rows = []
  let width = winwidth(0)
  """ adjust width for windows
  if exists('g:fzf_layout')
    if has_key(g:fzf_layout, 'window')
      if has_key(g:fzf_layout['window'], 'width')
        let width = g:fzf_layout['window']['width'] * width
      endif
    endif
  endif
  "" adjust based on 'max line length'
  let width= width - (max([len(line('$')), &numberwidth-1]) + 1)
  let g:fuzzymenu_align_adjust = get(g:, 'fuzzymenu_align_adjust', 0)
  let width = width + g:fuzzymenu_align_adjust

  for g in s:menuItems
    let gMetadata = g['metadata']
    let gItems = items(g['items'])
    if s:ShouldSkip(gMetadata, extension, tags)
      continue
    endif
    for i in gItems
      let k = i[0]
      let d = i[1]
      let def = s:merge(gMetadata, d)
      let help = has_key(def, 'help') ? def['help'] : ''
      if has_key(def, 'modes')
        let modes = def['modes']
        if  modes !~ currentMode
          " doesn't apply
          continue
        endif
      endif
      let key = s:key(k, def)

      " handle operation itself
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
      elseif has_key(def, 'visual')
        let cmd = has_key(def, 'hint') ? def['hint'] : def['visual']
        let cmd = s:color('cyan', 'visual: ') . cmd
      else
        " TODO: print error
        return []
      endif
      let mx = 0
      let row = [key, cmd]
      call add(rows, row)
    endfor
  endfor

  "" handle whitespace indentation
  for i in rows
    let gap=float2nr(width)-len(i[0])-25
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
  call sort(ret)
  return ret
endfunction

function! s:MenuSink(mode, fl, ll, arg) abort
  let key = fuzzymenu#Trim(split(a:arg, "\t")[0])
  let found = 0
  let def = {}
  for g in s:menuItems
    let gItems = g['items']
    for i in items(gItems)
      let k = i[0]
      let d = i[1]
      let def = s:merge(g['metadata'], d)
      if key == s:key(k, def)
        let found = 1
        break
      endif
    endfor
    if found == 1
      break
    endif
  endfor
  if !found
    echom printf("key '%s' not found!", key)
    "TODO: error how?
    return
  endif
  if has_key(def, 'exec')
    if a:mode == 'v' || a:mode == 'V' || a:mode == '^V'
      " execute on selected range
      " This will only be executed for entries explicitly tagged as 'visual'
      execute "'<,'>" . def['exec']
    else
      echom a:mode
      execute def['exec']
    endif
  elseif has_key(def, 'normal')
    call feedkeys(def['normal'])
  elseif has_key(def, 'visual')
    " note: don't even try to enter the _actual mode_.
    " gv seems to work for V and ^V (but gV/g^V don't)
    execute 'normal! gv'
    call feedkeys(def['visual'] . "\<CR>")
  else
    echo "invalid key for fuzzymenu: " . key
  endif
  if has_key(def, 'after')
   let after = def['after']
   execute after
  endif
endfunction

function! fuzzymenu#InsertModeIfNvim() abort
     if has("nvim-0.5")
         startinsert
     elseif has("nvim")
         call feedkeys('i')
     endif
endfunction

function! fuzzymenu#InsertMode() abort
     if has("nvim-0.5")
         startinsert
     elseif has("nvim")
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

function! fuzzymenu#RunVisual() abort range
  call fuzzymenu#Run({'visual': 1, 'mode': visualmode(), 'firstline': a:firstline, 'lastline': a:lastline})
endfunction

""
" @public
" Invoke fuzzymenu
function! fuzzymenu#Run(params) abort
  let mode = 'n'
  let visual = 0
  let tags = []
  let firstline = 0
  let lastline = 0
  if has_key(a:params, 'visual')
    " echo a:params
    if a:params['visual'] == 1
      let visual = a:params['visual']
      let mode = a:params['mode']
      let firstline = a:params['firstline']
      let lastline = a:params['lastline']
      call add(tags, 'visual')
    endif
  endif
  if has_key(a:params, 'tags')
    let tags = tags + a:params['tags']
  endif
  let filetype = expand("%:e")
  let sourceOpts = {'mode': mode, 'filetype': filetype, 'tags': tags}
  let options = ['--ansi', '--header', ':: Fuzzymenu - fuzzy select an item. _Try "Operator"_']
  if s:has_fzm_preview()
    let pluginbase = ''
    """ TODO other plugin managers
    if &runtimepath =~ ".vim/plugged"
      let pluginbase = '--pluginbase "~/.vim/plugged"'
    endif
    let options = options + ['--preview', 'fzmpreview vim:help '.pluginbase.'--piper bat -f 1 -k {}']
  endif
  let opts = {
    \ 'source': fuzzymenu#MainSource(sourceOpts),
    \ 'sink': function('s:MenuSink', [mode, firstline, lastline]),
    \ 'options': options}
  let fullscreen = 0
  if has_key(a:params, 'fullscreen')
    let fullscreen = a:params['fullscreen']
  endif
  return fzf#run(fzf#wrap('fuzzymenu', opts, fullscreen))
endfunction

function! s:has_fzm_preview() abort
  return executable('fzmpreview')
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
