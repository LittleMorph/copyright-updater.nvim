local M = {}

if vim.fn.has('nvim-0.7') == 0 then
    vim.api.nvim_err_writeln('copyright-updater.nvim requires Neovim version 0.7 or above')
    return
end

local options = {
    enabled = true,
    silent = false,
    mappings = {
        toggle = '<leader>C',
        enable = nil,
        disable = nil,
        update = nil
    },
    whitelist = false,
    filetypes = {}
}

local function update_copyright()
        -- Update copyright notice with current year
        -- @See vim Tip 1521 (https://vim.fandom.com/wiki/Automatically_Update_Copyright_Notice_in_Files)
        vim.api.nvim_exec( '%s:' ..
            '\\cCOPYRIGHT\\s*\\%((c)\\|©\\|&copy;\\)\\?\\s*' ..
            '\\%([0-9]\\{4}\\(-[0-9]\\{4\\}\\)\\?,\\s*\\)*\\zs' ..
            '\\(' ..
            '\\%(' .. os.date("%Y") .. '\\)\\@![0-9]\\{4\\}' ..
            '\\%(-' .. os.date("%Y") .. '\\)\\@!\\%(-[0-9]\\{4\\}\\)\\?' ..
            '\\&' ..
            '\\%([0-9]\\{4\\}-\\)\\?' ..
            '\\%(' .. (os.date("%Y") - 1) .. '\\)\\@!\\%([0-9]\\)\\{4\\}' ..
            '\\)' ..
            '\\ze\\%(\\%([0-9]\\{4\\}\\)\\@!.\\)*$:' ..
            '&,' .. os.date("%Y") .. ':e',
            false)
        vim.api.nvim_exec('%s:' ..
            '\\cCOPYRIGHT\\s*\\%((c)\\|©\\|&copy;\\)\\?\\s*' ..
            '\\%([0-9]\\{4}\\%(-[0-9]\\{4\\}\\)\\?,\\s*\\)*\\zs' ..
            '\\%(' .. os.date("%Y") .. '\\)\\@!\\([0-9]\\{4\\}\\)' ..
            '\\%(-' .. os.date("%Y") .. '\\)\\@!\\%(-[0-9]\\{4\\}\\)\\?' ..
            '\\ze\\%(\\%([0-9]\\{4\\}\\)\\@!.\\)*$:' ..
            '\\1-' .. os.date("%Y") .. ':e',
            false)
end

function M.update(force)
    force = force or false

    if force then
        update_copyright()
    elseif options.enabled and vim.bo.modified then
        if options.whitelist then
            -- File types are white-listed
            local whitelisted = false
            for _, ft in pairs(options.filetypes) do
                if ft == vim.bo.filetype then
                    whitelisted = true
                end
            end
            if not whitelisted then
                return
            end
        else
            -- File types are blacklisted
            for _, ft in pairs(options.filetypes) do
                if ft == vim.bo.filetype then
                    return
                end
            end
        end
        update_copyright()
    end
end

function M.enable()
    options.enabled = true
    if not options.silent then vim.api.nvim_out_write('Copyright Updater Enabled\n') end
end

function M.disable()
    options.enabled = false
    if not options.silent then vim.api.nvim_out_write('Copyright Updater Disabled\n') end
end

function M.toggle()
    if options.enabled then
        M.disable()
    else
        M.enable()
    end
end

function M.setup(opts)
    options = vim.tbl_deep_extend('force', options, opts or {})

    if type(options.enabled) ~= 'boolean' then
        vim.api.nvim_err_writeln('copyright-updater option enabled must be a boolean value')
        return
    end

    -- Set key mappings
    if options.mappings.toggle ~= '' and options.mappings.toggle ~= nil then
        vim.api.nvim_set_keymap('n', options.mappings.toggle, '<cmd>lua require("copyright-updater").toggle()<CR>', {noremap=true, silent=true, desc='Toggle Copyright Updater'})
    end
    if options.mappings.enable ~= '' and options.mappings.enable ~= nil then
        vim.api.nvim_set_keymap('n', options.mappings.enable, '<cmd>lua require("copyright-updater").enable()<CR>', {noremap=true, silent=true, desc='Enable Copyright Updater'})
    end
    if options.mappings.disable ~= '' and options.mappings.disable ~= nil then
        vim.api.nvim_set_keymap('n', options.mappings.disable, '<cmd>lua require("copyright-updater").disable()<CR>', {noremap=true, silent=true, desc='Disable Copyright Updater'})
    end
    if options.mappings.update ~= '' and options.mappings.update ~= nil then
        vim.api.nvim_set_keymap('n', options.mappings.update, '<cmd>lua require("copyright-updater").update(true)<CR>', {noremap=true, silent=true, desc='Update Copyrights'})
    end

    vim.api.nvim_create_augroup("copyright_updater", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
        desc = "Update Copyright",
        group = "copyright_updater",
        pattern = "*",
        callback = function() M.update() end
    })
end

vim.api.nvim_create_user_command('UpdateCopyright', function() M.update(true) end, {})

return M
