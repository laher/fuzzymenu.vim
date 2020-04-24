# fuzzymenu.vim

 * A menu for vim or neovim, built on top of [fzf](https://github.com/junegunn/fzf). 
 * Discover some vim features easily, without needing a mouse.

For now this includes a bunch of features which often need but I don't always remember. ...

## Install

Install fuzzymenu and dependencies using a plugin manager.

For example, use vim-plug:

```vim
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'laher/fuzzymenu.vim'
```

## Recommended mapping

The main way to invoke fuzzymenu is <Leader><Leader>. By default this means `\\`

```vim
	nmap <Leader><Leader> :Fzm<CR>
```

Once you have an appropriate mapping, you can use 'fuzzy search' to isolate menu items. Just start typing.

## Bundled menu items

 * various fzf.vim commands
 * various LSP features (requires vim-lsp: go to definition/implementation/references. rename, format, organize imports)
 * various go tools (requires gothx.vim)

## Extend fuzzymenu.vim

There are a few ways you can introduce mappings...

0. Create mappings in your own .vimrc (or init.vim) file
1. Submit a PR with additional mappings for this project. If it seems useful I will probably approve it.
2. Define mappings in your own plugin, which can be loaded whenever fuzzymenu.vim is installed.

## Defining mappings

Mappings look like this:

```vim
call fuzzymenu#Add('FZF: Key mappings', {'exec': 'Maps', 'mode': 'insert', 'help': 'vim key mappings'})
```
