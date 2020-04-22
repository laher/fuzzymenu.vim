# fuzzy-menu.vim - fuzzy menu using fzf

A fuzzy-finder menu for vim. Discover vim features easily, without needing a mouse.

For now this just includes go-to features which I don't always remember. ...

## Recommended config:

	nmap <Leader><Leader> :Fzm<CR>

Once you have an appropriate mapping

## Extend fuzzy-menu.vim

There are a few ways you can introduce mappings...

0. Create mappings in your own .vimrc (or init.vim) file
1. Submit a PR with additional mappings for this project. If it seems useful I will probably approve it.
2. Define mappings in your own plugin, which can be loaded whenever fuzzy-menu.vim is installed.

## Defining mappings

Mappings look like this:

```vim
call fzm#Add('FZF: Key mappings', {'exec': 'Maps', 'mode': 'insert', 'help': 'vim key mappings'})
```
