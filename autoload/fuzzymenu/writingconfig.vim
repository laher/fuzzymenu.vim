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
      \ 'number': {'d': 'Show line numbers on the sidebar.'},
      \ 'relativenumber': {'d': 'Show line number on the current line and relative numbers on all other lines.'},
      \ 'nonumber': {'d': 'Remove line numbers'},
      \ 'autoindent': {'d': 'New lines inherit the indentation of previous lines'},
      \ 'expandtab': {'d': 'Convert tabs to spaces.'},
      \ 'smarttab': {'d': 'Insert "tabstop" number of spaces when the “tab” key is pressed.'},
      \ 'hlsearch': {'d': 'Enable search highlighting.'},
      \ 'ignorecase': {'d': 'Case-insensitive searching.'},
      \ 'incsearch': {'d': 'Incremental search that shows partial matches.'},
      \ 'smartcase': {'d': 'Automatically switch search to case-sensitive when search query contains an uppercase letter.'},
      \ 'wrap': {'d': 'Enable line wrapping'},
      \ 'ruler': {'d': 'Always show cursor position.'},
      \ 'wildmenu': {'d': 'Display command line’s tab complete options as a menu.'},
      \ 'cursorline': {'d': 'Highlight the line currently under cursor.'},
      \ 'noerrorbells': {'d': 'Disable beep on errors.'},
      \ 'visualbell': {'d': 'Flash the screen instead of beeping on errors.'},
      \ 'g:fuzzymenu_vim_config_auto_write=1': {'d': 'Automatically write & reload vim config.'},
      \ }
" filetype indent on: Enable indentation rules that are file-type specific.
" shiftround: When shifting lines, round the indentation to the nearest multiple of “shiftwidth.”
" shiftwidth=4: When shifting, indent using four spaces.
" tabstop=4: Indent using four spaces.
" searching
"complete-=i: Limit the files searched for auto-completes.
"lazyredraw: Don’t update screen during macro and script execution.
"Text Rendering Options
"display+=lastline: Always try to show a paragraph’s last line.
"encoding=utf-8: Use an encoding that supports unicode.
"linebreak: Avoid wrapping a line in the middle of a word.
"scrolloff=1: The number of screen lines to keep above and below the cursor.
"sidescrolloff=5: The number of screen columns to keep to the left and right of the cursor.
"syntax enable: Enable syntax highlighting.
"User Interface Options
"laststatus=2: Always display the status bar.
"tabpagemax=50: Maximum number of tab pages that can be opened from the command line.
"colorscheme wombat256mod: Change color scheme.
"mouse=a: Enable mouse for scrolling and resizing.
"title: Set the window’s title, reflecting the file currently being edited.
"background=dark: Use colors that suit a dark background.
" Code Folding Options
"foldmethod=indent: Fold based on indention levels.
"foldnestmax=3: Only fold up to three nested levels.
"nofoldenable: Disable folding by default.
" Miscellaneous Options
"autoread: Automatically re-read files if unmodified inside Vim.
"backspace=indent,eol,start: Allow backspacing over indention, line breaks and insertion start.
"backupdir=~/.cache/vim: Directory to store backup files.
"confirm: Display a confirmation dialog when closing an unsaved file.
"dir=~/.cache/vim: Directory to store swap files.
"formatoptions+=j: Delete comment characters when joining lines.
"hidden: Hide files in the background instead of closing them.
"history=1000: Increase the undo limit.
"nomodeline: Ignore file’s mode lines; use vimrc configurations instead.
"noswapfile: Disable swap files.
"nrformats-=octal: Interpret octal as decimal when incrementing numbers.
"shell: The shell used to execute commands.
"spell: Enable spellchecking.
"wildignore+=.pyc,.swp: Ignore files matching these patterns when opening files based on a glob pattern.
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
  let settings = []
  for i in items(s:settings)
    let key = i[0]
    let val = i[1]
    let setter = 'set'
    if key =~ '^g:'
      let setter = 'let'
    endif
    let setting = printf("%s %s\t %s", setter, key, val['d'])
    call add(settings, setting)
  endfor
  return settings
endfunction

function! s:WriteSettingSink(mode, arg) abort
  let setting = split(a:arg, "\t")[0]

  "" TODO vimrc file setting
  let file = g:fuzzymenu_vim_config
  execute 'e ' . file
  execute 'normal! G$'

  if setting != ''
    " echo setting
    call append(line('$'), setting) 
    """ don't save. suggest
    let auto_write = g:fuzzymenu_vim_config_auto_write
    if auto_write == 1
      execute 'w'
      execute 'source '. file
      echom 'file written'
    endif
  endif
  execute 'normal! G$'
endfunction
