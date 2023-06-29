# java-find-sources
Find sources from any java symbol under the cursor

This is still under development - not ready to use

## Installation

### Using [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'quangnguyen30192/java-find-sources', { 'for': 'java' }
```

## Quick Start
Run JavaSyncSources to sync the sources jar from your local repository to a central sources

Bind the keymap (encourage to map to `gf` as it works like `gf` in vim)
```vimscript
nnoremap gf :JavaFindSources<cr>
nnoremap gT :JavaFindSources tabedit<cr>
```

## Commands

### To go to the file in current buffer, new tab, vertical or horizontal split
```vim
JavaFindSources ['e'|'tabnew'|'sp'|'vs']
```
## Configuration
TODO

# Currently support
- Package manager: maven
- Language: java
