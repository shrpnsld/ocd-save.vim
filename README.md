# ocd-save.vim

Save yourself from typing `:w<CR>` every time you edit a buffer in Vim, ocd-save will do that for you!

ocd-save autosaves buffers that are listed (`:h buflisted`), non-readonly (`:h readonly`), writable (`:h filewritable`) and normal (`:h buftype`). When `filetype plugin on` is used (`:h add-filetype-plugin`), Git buffers such as commit and merge files, are not autosaved.

## Installation

Use string `'shrpnsld/ocd-save.vim'` with your plugin manager and you're good to go.

## Configuration

### Excluding buffers

You can disable autosave for specific buffers by setting up an exclusion list `g:ocd_save_exclude`. Each element in this list is a funcref (`:h funcref`) that accepts a buffer number as an argument and returns `1` (`:h TRUE`) if this buffer *should not* be autosaved.

#### Example:

```vim
function CantBeSaved(buffer_number)
    return bufname(a:buffer_number) ==# 'cant-be-saved.txt'
endfunction

let g:ocd_save_exclude = [function('CantBeSaved')]
```

### Save message

To change or suppress `"file 555L, 4567B written"` message, set variable `g:ocd_save_message` with one of the following values:

 * `'<text>'` – set `<text>` as save message
 * `''` (empty string) – use default save message
 * `v:null` – suppress message

### Other

If you want to turn on autosave for Git buffers, you can do so by putting `let g:ocd_save_exclude_git = 0` into your Vim config.

Also, ocd-save pairs well with the `noswapfile` option (`:h noswapfile`).

### Note for [lazy.nvim](https://github.com/folke/lazy.nvim) users

These options should be set within the `init` function when listing ocd-save inside the lazy.nvim setup:

```lua
require("lazy").setup {
    { "shrpnsld/ocd-save.vim",
        init = function()
            vim.g.ocd_save_message = vim.v.null,
        end },
}
```

## Commands

`:OcdSaveOn` – turn on for all buffers.

`:OcdSaveOff` – turn off for all buffers.

`:OcdSaveOnHere` – turn on for current buffer.

`:OcdSaveOffHere` – turn off for current buffer.
