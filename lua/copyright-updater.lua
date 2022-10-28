local M = {}

local assert = require "luassert"

if vim.fn.has('nvim-0.7') == 0 then
    vim.api.nvim_err_writeln('copyright-updater.nvim requires Neovim version 0.7 or above')
    return
end

local options = {
    enabled = true,
    silent = false,
    style = {
        kind = 'advanced', -- advanced | simple
        simple = {
            force = false -- Allow removing existing info
        }
    },
    mappings = {
        toggle = '<leader>C',
        enable = nil,
        disable = nil,
        update = nil
    },
    limiters = {
        range = '%', -- substitution range
        files = {
            type_whitelist = false,
            types = {}
        }
    }
}

local function append_comma_clause()
    vim.api.nvim_exec(options.limiters.range .. 's:' ..
        '\\cCOPYRIGHT\\s*\\%((c)\\|©\\|&copy;\\)\\?\\s*' ..
        '\\%([0-9]\\{4}\\(-[0-9]\\{4\\}\\)\\?,\\s*\\)*' ..
        '\\zs' ..
        '\\(' ..
        '\\%(' .. os.date("%Y") .. '\\)\\@![0-9]\\{4\\}' ..
        '\\%(-' .. os.date("%Y") .. '\\)\\@!\\%(-[0-9]\\{4\\}\\)\\?' ..
        '\\&' ..
        '\\%([0-9]\\{4\\}-\\)\\?' ..
        '\\%(' .. (os.date("%Y") - 1) .. '\\)\\@!\\%([0-9]\\)\\{4\\}' ..
        '\\)' ..
        '\\ze' ..
        '\\%(\\%([0-9]\\{4\\}\\)\\@!.\\)*$:' ..
        '&,' .. os.date("%Y") .. ':e',
        false)
end

local function update_range_clause()
    vim.api.nvim_exec(options.limiters.range .. 's:' ..
        '\\cCOPYRIGHT\\s*\\%((c)\\|©\\|&copy;\\)\\?\\s*' ..
        '\\%([0-9]\\{4}\\%(-[0-9]\\{4\\}\\)\\?,\\s*\\)*' ..
        '\\zs' ..
        '\\%(' .. os.date("%Y") .. '\\)\\@!\\([0-9]\\{4\\}\\)' ..
        '\\%(-' .. os.date("%Y") .. '\\)\\@!\\%(-[0-9]\\{4\\}\\)\\?' ..
        '\\ze' ..
        '\\%(\\%([0-9]\\{4\\}\\)\\@!.\\)*$:' ..
        '\\1-' .. os.date("%Y") .. ':e',
        false)
end

local function collapse_to_range_clause()
    vim.api.nvim_exec(options.limiters.range .. 's:' ..
        '\\cCOPYRIGHT\\s*\\%((c)\\|©\\|&copy;\\)\\?\\s*' ..
        '\\zs' ..
        '\\%(' .. os.date("%Y") .. '\\)\\@!\\([0-9]\\{4}\\)\\%([,-]\\?\\%([0-9]\\{4\\}\\)\\)*' ..
        '\\ze' ..
        '\\%(\\%([0-9]\\{4\\}\\)\\@!.\\)*$:' ..
        '\\1-' .. os.date("%Y") .. ':e',
        false)
end

function M.update(force)
    force = force or false

    if not force then
        if not options.enabled or not vim.bo.modified then
            return
        end

        if options.limiters.files.type_whitelist then
            -- File types are white-listed
            local whitelisted = false
            for _, ft in pairs(options.limiters.files.types) do
                if ft == vim.bo.filetype then
                    whitelisted = true
                end
            end
            if not whitelisted then
                return
            end
        else
            -- File types are blacklisted
            for _, ft in pairs(options.limiters.files.types) do
                if ft == vim.bo.filetype then
                    return
                end
            end
        end
    end

    local report = vim.api.nvim_get_option('report')
    if options.silent then vim.opt.report = 10000 end -- disable reporting

    if options.style.kind == 'advanced' then
        -- Append comma clauses first to prevent range update from spanning skipped years
        append_comma_clause()
        update_range_clause()
    elseif options.style.kind == 'simple' then
        if options.style.simple.force then
            -- Collapse advanced copyright lines to simple ones
            collapse_to_range_clause()
        else
            -- Update only simple lines
            update_range_clause()
        end
    else
        vim.api.nvim_err_writeln('copyright-updater.nvim unknown option value for style.kind')
    end

    if options.silent then vim.opt.report = report end -- restore reporting
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

local function verify_options()
    assert(type(options.enabled) == "boolean", "Option 'enabled' must be either true or false")
    assert(type(options.silent) == "boolean", "Option 'silent' must be either true or false")

    -- style
    assert(type(options.style) == "table", "Option 'style' must be a table")
    assert(type(options.style.kind) == "string" and
        (options.style.kind == "advanced" or options.style.kind == "simple"),
        "Option 'style.kind' must be either 'advanced' or 'simple'")
    assert(type(options.style.simple) == "table", "Option 'style.simple' must be a table")
    assert(type(options.style.simple.force) == "boolean", "Option 'style.simple.force' must be either true or false")

    -- mappings
    assert(type(options.mappings) == "table", "Option 'mappings' must be a table")
    assert(type(options.mappings.toggle) == "string" or type(options.mappings.update) == "nil", "Option 'mappings.toggle' must be a string or nil")
    assert(type(options.mappings.update) == "string" or type(options.mappings.update) == "nil", "Option 'mappings.update' must be a string or nil")
    assert(type(options.mappings.enable) == "string" or type(options.mappings.update) == "nil", "Option 'mappings.enable' must be a string or nil")
    assert(type(options.mappings.disable) == "string" or type(options.mappings.update) == "nil", "Option 'mappings.disable' must be a string or nil")

    -- limiters
    assert(type(options.limiters) == "table", "Option 'limiters' must be a table")
    assert(type(options.limiters.range) == "string", "Option 'limiters.range' must be a string")
    assert(type(options.limiters.files) == "table", "Option 'limiters.files' must be a table")
    assert(type(options.limiters.files.types) == "table", "Option 'limiters.files.types' must be a table")
    assert(type(options.limiters.files.type_whitelist) == "boolean", "Option 'limiters.files.type_whitelist' must be either true or false")

    for i,_ in pairs(options.limiters.files.types) do
        assert(type(options.limiters.files.types[i]) == "string", "Entries in option table 'limiters.files.types' must be of type string")
    end
end

function M.setup(opts)
    options = vim.tbl_deep_extend('force', options, opts or {})

    verify_options()

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

    vim.api.nvim_create_user_command('UpdateCopyright', function() M.update(true) end, {})
end

return M
