# java-find-sources
Find sources from any java symbol under the cursor

This is still under development - not ready to use

## Installation

### Using [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'quangnguyen30192/java-source-finder', { 'for': 'java' }
```

## Quick Start
Run JavaSyncSources to sync the sources jar from your local repository to a central sources

Bind the keymap (encourage to map to `gf` as it works like `gf` in vim)
```vimscript
nnoremap gf :JavaFindSources<cr>
```
## Configuration
```lua
{
  "quangnguyen30192/java-source-finder.nvim"
  ft = "java",
  dependencies = {
    'vijaymarupudi/nvim-fzf',
  }
  config = function()
    require("java-source-finder").setup({
      local_library = vim.env["HOME"] .. "/.m2/src",
      package_manager_repository = vim.env["HOME"] .. "/.m2/repository",
      java_runtime = "/opt/homebrew/opt/java11/libexec/openjdk.jdk/Contents/Home",
      plugin_path = vim.env["HOME"] .. "/dev/repository/personal/java-source-finder",
    })
  end,
}

```

# Currently support
- Package manager: maven
- Language: java
