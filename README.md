# copyright-updater.nvim

A [Neovim](https://neovim.io) plugin to automatically update copyright messages when saving a modified buffer.

Inspired by [Vim Tip 1521](https://vim.fandom.com/wiki/Automatically_Update_Copyright_Notice_in_Files) by user Fritzophrenic.

In the default configuration the plugin updates any line containing the word copyright followed by at least one year when the buffer is written.
Common copyright symbols like `©`, `(c)` and `&copy;` can optionally be between the copyright word and the year specification.

The plugin supports different copyright styles, formats and update strategies.
It is also possible to apply limiters like file type, file name, buffer range and post match patterns (E.g. to only update copyright statements that contain a certain company name).
See the [Configuration](#configuration) section for details.

## Requirements

- Neovim >= 0.11.0
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) (for running tests)

For older versions of Neovim, use the tag `neovim-below-0.11.0`.

## Installation

Install using your favorite plugin manager

### [lazy](https://github.com/folke/lazy.nvim)

```lua
{
    'LittleMorph/copyright-updater.nvim',
    event: 'BufModifiedSet', -- Delay loading until a buffer is modified
    opts = {}
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'LittleMorph/copyright-updater.nvim',
    config = function()
        require('copyright-updater').setup()
    end
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```lua
Plug 'LittleMorph/copyright-updater.nvim'
```

## Usage

For basic usage with default configuration:

```lua
require('copyright-updater').setup()
```

### Triggering an update

There are three ways to trigger an update.

1. Write the buffer - will trigger the auto command
1. Use the mapping bound to `mappings.update`
1. Use the Ex command `:UpdateCopyright`

Using the Ex command allows overriding the configured limiters.
To override the range limiter just specify a range.
To override the post pattern, append the new pattern after the Ex command.
To override all other limiters, use the bang modifier -
Note that the configured range and post pattern is ignored when using the bang modifer,
but a range and/or post pattern specified as part of the Ex command is respected.
E.g. to update the entire buffer ignoring all configured limiters and the post pattern, use:

```
:%UpdateCopyright!
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
    -- Return cursor to current line after update
    return_cursor = false,
    style = {
        -- Advanced style allows multiple ranges separated by comma
        -- Simple style use only a single range
        kind = 'advanced',
        advanced = {
            space_after_comma = false,
            force = false -- Apply the space_after_comma setting to existing commas
        },
        simple = {
            force = false, -- Allow reducing advanced style to simple style
        }
    },
    -- To disable a key mapping, either assign it an empty value or nil
    mappings = {
        toggle = '<leader>C',  -- Toggle the plugin on/off
        enable = nil,  -- Enable the plugin globally
        disable = nil, -- Disable the plugin globally
        update = nil   -- Update current buffer
    },
    limiters = {
        range = '%', -- Only update copyright statements in this range
        post_pattern = '', -- E.g. a company name to match after the year list
        files = {
            -- Change the types list from a blacklist to a whitelist
            type_whitelist = false,
            -- List of file types to blacklist (or whitelist)
            types = {},
            -- Change the names list from a blacklist to a whitelist
            name_whitelist = false,
            -- List of file name patterns to blacklist (or whitelist)
            -- Matches on the entire path, not just the filename
            names = {}
        }
    }
}
```

See `:help copyright-updater` once the plugin is installed for more details, or read it [here](doc/copyright-updater.txt).

## Style examples

All examples assume the current year is 2022.

### Advanced style

```lua
style = {
    kind = 'advanced'
}
```

Before update:

```
# Copyright (c) 2018-2021 Corp A/S
# copyright &copy; 2021 Corp A/S
# COPYRIGHT © 2019 Corp A/S
# CoPyRiGhT 2018-2019,2021 Corp A/S
# Copyright (c) 2018-2020
```

After update:

```
# Copyright (c) 2018-2022 Corp A/S
# copyright &copy; 2021-2022 Corp A/S
# COPYRIGHT © 2019,2022 Corp A/S
# CoPyRiGhT 2018-2019,2021-2022 Corp A/S
# Copyright (c) 2018-2020,2022
```

### Simple style

```lua
style = {
    kind = 'simple',
    simpel = {
        force = false
    }
}
```

Before update:

```
# Copyright (c) 2018-2021 Corp A/S
# copyright &copy; 2021 Corp A/S
# COPYRIGHT © 2019 Corp A/S
# CoPyRiGhT 2018-2019,2021 Corp A/S
```

After update:

```
# Copyright (c) 2018-2022 Corp A/S
# copyright &copy; 2021-2022 Corp A/S
# COPYRIGHT © 2019-2022 Corp A/S
# CoPyRiGhT 2018-2019,2021-2022 Corp A/S
```

### Simple style forced

```lua
style = {
    kind = 'simple',
    simpel = {
        force = true
    }
}
```

Before update:

```
# CoPyRiGhT 2018-2019,2021 Corp A/S
# Copyright (c) 2018,2020
```

After update:

```
# CoPyRiGhT 2019-2022 Corp A/S
# Copyright (c) 2018-2022
```

## Found a bug?

Please open an issue with a minimal config and buffer content to reproduce the bug.
