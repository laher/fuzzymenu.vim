""
" @public
" Invoke fuzzymenu to map a key
function! fuzzymenu#writingconfig#MapKey(params) abort range
  let mode = 'n'
  let filetype = expand("%:e")
  let opts = {
    \ 'source': fuzzymenu#MainSource({'mode': mode, 'filetype': filetype}),
    \ 'sink': function('s:MapKeySink', [mode]),
    \ 'options': ['--ansi', '--header', ':: Fuzzymenu - fuzzy select an item in order to create a mapping']}
  let opts[g:fuzzymenu_position] = g:fuzzymenu_size
  let fullscreen = 0
  if has_key(a:params, 'fullscreen')
    let fullscreen = a:params['fullscreen']
  endif
  call fzf#run(fzf#wrap('fuzzymenu', opts, fullscreen))
endfunction

function! s:MapKeySink(mode, arg) abort
  let key = s:trim(split(a:arg, "\t")[0])
  echom key
  let found = 0
  let def = {}
  let gMeta = {}
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

  call inputsave()
  let keys = input('Key mapping (e.g. '<leader>x'): ', '<leader>')
  call inputrestore()

  "" TODO vimrc file setting
  let file = g:fuzzymenu_vim_config
  execute 'e ' . file
  execute 'normal! G$'

  let mapping = ''
  if has_key(def, 'exec')
    if a:mode == 'v'
      " execute on selected range
      " TODO: only support range when it makes sense to? ... or should we just allow it? Someone can always just use normal-mode if it fails
      let mapping = "vmap ".keys." :" . def['exec'] . "<CR>"
    else
      let mapping = "nmap ".keys." :" . def['exec'] . "<CR>"
    endif
  elseif has_key(def, 'normal')
    " TODO: check mode?
      echom "nmap XXX to " . def['normal']
      let mapping = "nmap ".keys." " . def['normal']
  else
    echom "invalid key for fuzzymenu: " . key
  endif
  if has_key(def, 'after')
   let after = def['after']
   """ TODO ...  I think we can leave this out (only needed during an Fzm invocation)
  endif
  if mapping != ''
    echo mapping
    call append(line('$'), mapping) 
    """ don't save. suggest
  endif
endfunction

let s:settings = {
      \ 'number': 'Line Numbers',
      \ 'relativenumber': 'Relative Line Numbers',
      \ 'nonumber': 'Remove line numbers',
      \ }

""
" @public
" Invoke fuzzymenu to map a key
function! fuzzymenu#writingconfig#WriteSetting() abort range
  let mode = 'n'
  let opts = {
    \ 'source': s:SettingsSource(),
    \ 'sink': function('s:WriteSettingSink', [mode]),
    \ 'options': ['--ansi', '--header', ':: Fuzzymenu - fuzzy select an item in order to create a mapping']}
  let opts[g:fuzzymenu_position] = g:fuzzymenu_size
  let fullscreen = 0
  call fzf#run(fzf#wrap('fuzzymenu', opts, fullscreen))
endfunction

function! s:SettingsSource() abort
  let operators = []
  for i in items(s:settings)
    let key = i[0]
    let val = i[1]
    let operator = printf("set %s\t %s", key, val)
    call add(operators, operator)
  endfor
  return operators
endfunction

function! s:WriteSettingSink(mode, arg) abort
  let setting = split(a:arg, "\t")[0]

  "" TODO vimrc file setting
  let file = g:fuzzymenu_vim_config
  execute 'e ' . file
  execute 'normal! G$'

  if setting != ''
    echo setting
    call append(line('$'), setting) 
    """ don't save. suggest
  endif
  execute 'normal! G$'
  call popup_notification('hello')
endfunction
