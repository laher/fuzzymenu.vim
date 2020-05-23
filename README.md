# fuzzymenu.vim ![build-status](https://travis-ci.org/laher/fuzzymenu.vim.svg?branch=master)

fuzzymenu is a _[preview release]_ menu plugin for vim or neovim, built on top of [fzf](https://github.com/junegunn/fzf), with a curated list of menu items.

Use `vim` more easily, but still learn vim - you won't _need_ to memorise so many commands and mappings, BUT fuzzymenu will help by reminding you how to use those features directly, as you select a menu item. Fuzzymenu provides:

 * A single starting point for oodles of discoverable functionality (for me it's `<space><space>`).
 * A _curated_ set of features - 'finding things', 'learning vim things', and 'IDE things'.
 * A fuzzy-search menu is faster and easier to use than heirarchical menus.
 * Use vim better, faster:
   * Use vim in the usual way, _AND_ like an IDE (e.g. LSP integration for semantic code navigation; also, menu items contain 'IDE lingo' keywords _alongside_ the vim terminology).
   * Learn to use vim features (e.g. text objects and motions) with searchable prompts. 
   * Extend the functionality by adding more items, and telling fuzzymenu about custom text objects.

> This is still a preview version - I think it’s very useful already - please try it out.

# Intro video

Here's an intro to an early version of fuzzymenu (watch on youtube.com).

[![Intro to fuzzymenu](http://img.youtube.com/vi/UGtehP21teY/0.jpg)](http://www.youtube.com/watch?v=UGtehP21teY "Intro to fuzzymenu")

It's 10 minutes - wow I spoke a lot. If that sounds like too much, just install, below, and hit `<leader><leader>` to start playing.

## Install

Install fuzzymenu and dependencies using your preferred plugin manager.

For example, using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'laher/fuzzymenu.vim'
```

Then, for convenience, a mapping such as `<Leader><Leader>`, `<Leader>m`, or `<c-p>`:

```vim
  nmap <Leader><Leader> <Plug>Fzm
  vmap <Leader><Leader> <Plug>FzmVisual
```

 * By default, the leader key is mapped to `\`. (I map leader to ' ': `mapleader=' '`)
 * _The fzf plugin itself depends on a binary file `fzf`. If you don't have it already, `:call fzf#install()` (or see fzf docs)._

## Usage

_See also [help docs](./doc/fuzzymenu.txt) - especially for function signatures._

### 1. Invoke fuzzymenu

You can invoke fuzzymenu with the above mapping if set, or a command `:Fzm` (fullscreen with `:Fzm!`).

### 2. Using the menu

#### 2a. using fzf

fuzzymenu uses the `fzf` user interface.

 * Type some letters to filter the menu contents. 
 * fzf will match entries containing the letters you type, BUT they don't need to appear consecutively in the target menu entry. 
  * e.g. Typing `cnsctv` would match an entry named `consecutive`. 
  * e.g.2. `vto` would not match - those letters do exist in the word `consecutive`, but in a different order. 
 * fzf uses case-insensitive fuzzy search.
 * Use Up/Down arrows (or k/j), to select the item you want. 
 * Press Enter to select the item, which _may_ be another fzf entry, in some cases.
 * To cancel, `Esc`/`Ctrl-C`/`:q` to cancel.

#### 2b. Fuzzymenu specifics: 

Fuzzymenu entries are intended to be easy to search for:

* You can search using the name of the item (which may be specified by 'general IDE terminology' AND 'vim terminology'. e.g. 'search buffers' vs 'Find in open files').
* search using part of the command name which will be executed.
* Search by entry [tags]. 
* If you want to search for a combination of these, then order is important - `[tag]name :command`.

### 3. Learning vim through fuzzymenu

Fuzzymenu isn't a general purpose vim helper. Try `vimtutor` and many other resources.
However, fuzzymenu does make a small effort to teach you how to use its content directly...

* Please see the 'definition' on the right of each menu item - the definition is also searchable.
* Menu items use one of four types of invocation:
  * Commands. From normal mode, type `:`, e.g. `:Helptags`
  * Function calls. From normal mode, type `:call `, e.g. `:call func#name()`
  * Normal mode input sequence. From normal mode, just type the sequence, e.g. `ggVG`
  * Interactive (multi-step) features (typically using fzf or a basic prompt). Where appropriate the normal-mode sequence will be shown (e.g. try 'yank')
* Use `:Fzm` -> `help` (another fzf menu, `:Helptags`) to navigate vim's help system more easily.

## Bundled menu items

fuzzymenu comes with a GROWING list of menu items (please submit more via pull requests).

 * Some interactive helpers for normal-mode commands & text-objects (yank, delete, change some text).
 * Various commands from fzm.vim.
 * Various LSP features (requires [vim-lsp](https://github.com/prabirshrestha/vim-lsp): go to definition/implementation/references. rename, format, organize imports).
 * Various git features (requires [fugitive](https://github.com/tpope/vim-fugitive) ).
 * Various go tools (requires [gothx.vim](https://github.com/laher/gothx.vim) ).
 * A few fundamentals: setting case-[in]sensitive searches, show/hiding line numbers and whitespace characters.

| Area           | Dependencies   | Registered by fuzzymenu | Registered by dependency |
|----------------|----------------|-------------------------|--------------------------|
| fundamentals   | n/a            | [x]                     |                          |
| FZF            | (fzf, fzf.vim) | [x]                     |                          |
| LSP            | [vim-lsp](https://github.com/prabirshrestha/vim-lsp) | [x] |        |
| Go             | [gothx](https://github.com/laher/gothx.vim)          |     | [x]    |
| Go             | [vim-go](https://github.com/fatih/vim-go)            | [x] |        |
| git            | [fugitive](https://github.com/tpope/vim-fugitive)    | [x] |        |

More to follow... _For example, I'm keen to support multiple providers for given features ... for LSP, this could include vim-lsp, coc.vim & languageclient-neovim. For Go, gothx.vim and vim-go._

## Extend fuzzymenu.vim

There are a few ways you can introduce your own entries...

0. Create entries in your own .vimrc (or init.vim) file
1. Submit a PR with additional menu items for this project. If it seems useful I will probably approve it.
2. Define mappings in your own plugin, which can be loaded whenever fuzzymenu.vim is installed.

## Defining entries

Adding an entry to your vimrc, looks like one of these 3 examples:

```vim
call fuzzymenu#Add('FZF: Key mappings', {'exec': 'Maps', 'after': 'call fuzzymenu#InsertMode()', 'help': 'vim key mappings'})
call fuzzymenu#Add('Select all', {'exec': 'normal! ggVG'})
call fuzzymenu#Add('LSP: rename', {'exec': 'LspRename', 'for': { 'exists': 'g:lsp_loaded' }})
```
The first parameter is a unique key. The second parameter is a map of options:

- `exec` is mandatory. This is the command which will be invoked. For example, `'Maps'` above is the same as running `:Maps` from normal mode. Use `call MyFunction()` to run a function. Use `normal!` to run some normal mode commands.
- `after` is optional. Fuzzymenu runs this command _after_ this command. It is not printed in the fzf entry. For example, if you need fuzzymenu to drop into insert mode after running your command, specify `'after': 'call fuzzymenu#InsertMode()'`. _Insert mode is necessary for fzf features._
- `help` is for adding an additional explanation.
- `for` specifies a filetype. 

## Limitations

There will be some things which aren't well supported _yet_. 

 * One example: the menu item's 'exec' is triggered inside an fzf 'sink' function. For many operations, this is fine, but in some cases the context of the invocation might pick up some context from fzf's popup window.

> For example, an 'exec' with `<c-r><c-w>`, such as 'GGrep <c-r><c-w>', will try to find the word under the cursor of the fzf popup window, rather than the originating buffer.

For now the workaround is to wrap the fzf call into a function that uses `expand("<cword>")`. See `fuzzymenu#GitGrepUnderCursor()`, for example.

## Configuration

See [./doc/fuzzymenu.txt](./doc/fuzzymenu.txt) for configuration options ...


## For contributors

Some guidance for anyone wanting to contribute ...

1. I'm keen to implement menu entries for particular areas of functionality:

 * Fundamentals - any more general purpose tools like 'set nonumber', where the naming is not intuitive? Give it a more intuitive key name (fuzzymenu will still find it by the original name if necessary).
 * LSP clients - keen to add coc, LanguageClient-neovim, etc.
 * FZF - any more useful fzf-based commands? Happy to add the definitions here.
 * Language-specific features ... _BUT I'd prefer NOT to include language-specific features whenever LSP has an equivalent._

2. I'd like to extend the usefulness of the plugin a little:

 * Hint the ':help' for a given entry
 * Show key mappings for a given entry

_I'd love to make these available as a preview window. I'm not exactly sure how to do that (typically fzf.vim uses an external program - a wrapper around cat/bat. I don't know how to print a vim help from an external command - vim/view or otherwise...)._
Alternatively, it might just work to implement a key mapping within the fzf window, to view help/mappings for a menu item - including some visual cue.

### Defining an entry from your plugin

A plugin can add some entries to fuzzymenu, but just make sure to add them _only_ when fuzzymenu is installed. Like this (for an imaginary plugin `teddyplugin`, which works on `.ted` files):

```vim
if exists('g:fuzzymenu_loaded')
  call fuzzymenu#Add('teddy bingo', {'exec': 'TddyBingo', 'for': {'ft': 'ted'}})
endif
```

From within your plugin, please use a central `plugin/*.vim` file to define filetype-specific mappings (rather than `ftplugin/`). fuzzymenu will look after which entries to show based on the `for` parameter and the filetype. It's just how fuzzymenu's registration mechanism works.


## Background 

 * I've always felt that vim could be made more intuitive - this is my first attempt.
 * The project was inspired by a combination of fzf (fuzzy finders) and spacemacs/(spacevim), and Intellij's 'shift-shift' omni finder - providing an easily discoverable feature set, where you only need to remember a single key mapping.
 * The advantage of a fuzzy menu is the _immediacy_ of a large, filterable, top-level menu.

# Status, Plans & TODOs

This is still very early. 

**Some signatures and data structures may change, and documentation is incomplete.**

Some planned features:

 * Menu Items:
  - [x] Interactive (2-step) normal mode commands (yank,delete,change,...) + motions/objects
  - [ ] Interactive search/replace for regions/files/next/...
  - [ ] Macro support
  - [ ] Registers? (or maybe vim-peekaboo integration if it's too hard)
  - [ ] More LSP clients (coc, languageclient-neovim, ...)
  - [ ] Some more 'vim fundamentals' 
 * UX
  * [ ] Per-menu-item help with `<c-h>` or something (maybe even a preview window?)
  * [ ] Probably redesign the layout of a line
  * [ ] hook into vim gui menus with a single item
  * [ ] Fancy prompt for ranges, etc?
