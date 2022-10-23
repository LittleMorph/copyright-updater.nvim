# copyright-updater.nvim

A [Neovim](https://neovim.io) plugin to automatically update copyright messages when saving a modified buffer.

Inspired by [Vim Tip 1521](https://vim.fandom.com/wiki/Automatically_Update_Copyright_Notice_in_Files) by user Fritzophrenic.

Updates any line that matches (case insensitively) this simplified regex: `copyright ((c)|©|&copy;)? [0-9]{4}`.

Example lines before update:

```
# Copyright (c) 2018-2021 Corp A/S
# copyright &copy; 2021 Corp A/S
# COPYRIGHT © 2019 Corp A/S
# CoPyRiGhT 2018-2019,2021 Corp A/S
# Copyright (c) 2018-2020
```

After copyright update:

```
# Copyright (c) 2018-2022 Corp A/S
# copyright &copy; 2021-2022 Corp A/S
# COPYRIGHT © 2019,2022 Corp A/S
# CoPyRiGhT 2018-2019,2021-2022 Corp A/S
# Copyright (c) 2018-2020,2022
```

## Requirements

- Neovim >= 0.7.0

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use {
    'LittleMorph/copyright-updater.nvim'
}
```

Using [vim-plug](https://github.com/junegunn/vim-plug):
```lua
Plug 'LittleMorph/copyright-updater.nvim'
```

## Usage

For basic usage with default configuration:

```lua
require('copyright-updater').setup()
```

or directly using [packer.nvim]:

```lua
use {
    'LittleMorph/copyright-updater.nvim'
    config = function()
        require('copyright-updater').setup()
    end
}
```

## Configuration

Configuration can be passed to the setup function.
Here is an example with the default options:

```lua
require('copyright-updater').setup {
    -- Whether the plugin should be active on startup
    enabled = true,
    -- Print status when enabling, disabling, or toggling the plugin
    silent = false,
    -- To disable a key mapping, either assign it an empty value or nil
    mappings = {
        toggle = '<leader>C',  -- Toggle the plugin on/off
        enable = nil,  -- Enable the plugin globally
        disable = nil, -- Disable the plugin globally
        update = nil   -- Force update current buffer
    },
    -- Change filetypes list to a whitelist (as opposed to a blacklist)
    whitelist = false,
    -- List of file types to blacklist (or whitelist if whitelist=true)
    filetypes = {}
}
```

See `:help copyright-updater` once the plugin is installed for more details.
