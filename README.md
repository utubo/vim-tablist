⚠This is the beta version.

# vim-tablist

TODO

list tabs and show, close and move tabs.

## Install

```vim
call dein#add('utubo/vim-tablist')
nnoremap <silent> <Leader>T :<C-u>call tablist#Show()<CR>
```

## Keymaps
```
q Close Tablist
<CR> Show tab
r Refresh list
d Close tab
D Close tab (fource)
J Move to right
K Move to left
o New tab (right)
O New tab (left)
```

