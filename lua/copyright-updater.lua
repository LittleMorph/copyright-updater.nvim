local M = {}

local assert = require "luassert"

if vim.fn.has('nvim-0.7') == 0 then
    vim.api.nvim_err_writeln('copyright-updater.nvim requires Neovim version 0.7 or above')
    return
end

local options = {
    enabled = true,
    silent = false,
    return_cursor = false,
    style = {
        kind = 'advanced', -- advanced | simple
        advanced = {
            space_after_comma = false,
            force = false -- Apply the space_after_comma setting to existing commas
        },
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
        post_pattern = '',
        files = {
            type_whitelist = false,
            types = {},
            name_whitelist = false,
            names = {}
        }
    }
}

local function append_comma_clause(range, post_pat)
    local space = options.style.advanced.space_after_comma and ' ' or ''

    vim.api.nvim_exec(range .. 's:\\m' ..
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
        '\\%(\\%([0-9]\\{4\\}\\)\\@!.\\)*' ..
        post_pat .. '$:' ..
        '&,' .. space .. os.date("%Y") .. ':e',
        false)
    vim.fn.histdel('/', -1)
end

local function update_comma_clauses(range, post_pat)
    local space = options.style.advanced.space_after_comma and ' ' or ''

    vim.api.nvim_exec(range .. 'g:\\m' ..
        '\\cCOPYRIGHT\\s*\\%((c)\\|©\\|&copy;\\)\\?\\s*' ..
        '.*' ..
        post_pat .. '$' ..
        ':s:\\m' ..
        '\\([0-9]\\{4\\}\\)\\s*,\\s*:' ..
        '\\1,' .. space .. ':g',
        false)
    vim.fn.histdel('/', -1)
end

local function update_range_clause(range, post_pat)
    vim.api.nvim_exec(range .. 's:\\m' ..
        '\\cCOPYRIGHT\\s*\\%((c)\\|©\\|&copy;\\)\\?\\s*' ..
        '\\%([0-9]\\{4}\\%(-[0-9]\\{4\\}\\)\\?,\\s*\\)*' ..
        '\\zs' ..
        '\\%(' .. os.date("%Y") .. '\\)\\@!\\([0-9]\\{4\\}\\)' ..
        '\\%(-' .. os.date("%Y") .. '\\)\\@!\\%(-[0-9]\\{4\\}\\)\\?' ..
        '\\ze' ..
        '\\%(\\%([0-9]\\{4\\}\\)\\@!.\\)*' ..
        post_pat .. '$:' ..
        '\\1-' .. os.date("%Y") .. ':e',
        false)
    vim.fn.histdel('/', -1)
end

local function collapse_to_range_clause(range, post_pat)
    vim.api.nvim_exec(range .. 's:\\m' ..
        '\\cCOPYRIGHT\\s*\\%((c)\\|©\\|&copy;\\)\\?\\s*' ..
        '\\zs' ..
        '\\%(' .. os.date("%Y") .. '\\)\\@!\\([0-9]\\{4}\\)\\%(\\s*[,-]\\?\\s*\\%([0-9]\\{4\\}\\)\\)*' ..
        '\\ze' ..
        '\\%(\\%([0-9]\\{4\\}\\)\\@!.\\)*' ..
        post_pat .. '$:' ..
        '\\1-' .. os.date("%Y") .. ':e',
        false)
    vim.fn.histdel('/', -1)
end

local function within_filetype_limits()
    if options.limiters.files.type_whitelist then
        -- File types are white-listed
        local whitelisted = false
        for _, ft in pairs(options.limiters.files.types) do
            if ft == vim.bo.filetype then
                whitelisted = true
            end
        end
        if not whitelisted then
            return false
        end
    else
        -- File types are blacklisted
        for _, ft in pairs(options.limiters.files.types) do
            if ft == vim.bo.filetype then
                return false
            end
        end
    end
    return true
end

local function within_filename_limits()
    local file = vim.api.nvim_buf_get_name(0)
    if options.limiters.files.name_whitelist then
        -- File names are white-listed
        local whitelisted = false
        for _, pat in pairs(options.limiters.files.names) do
            if vim.regex(pat):match_str(file) ~= nil then
                whitelisted = true
            end
        end
        if not whitelisted then
            return false
        end
    else
        -- File names are blacklisted
        for _, pat in pairs(options.limiters.files.names) do
            if vim.regex(pat):match_str(file) ~= nil then
                return false
            end
        end
    end
    return true
end

function M.update(opts)
    opts = opts or {}
    opts.force = opts.force or false
    opts.range = opts.range or options.limiters.range
    opts.post_pat = opts.post_pat or options.limiters.post_pattern

    if not vim.bo.modifiable then
        vim.api.nvim_err_writeln('copyright-updater.nvim buffer is not modifiable')
        return
    end

    if not opts.force then
        if not options.enabled or not vim.bo.modified then
            return
        end
        if not within_filetype_limits() then
            return
        end
        if not within_filename_limits() then
            return
        end
    end

    local report = vim.api.nvim_get_option('report')
    if options.silent then vim.opt.report = 10000 end -- disable reporting

    -- save cursor position
    local position = vim.fn.winsaveview()

    if options.style.kind == 'advanced' then
        -- Append comma clauses first to prevent range update from spanning skipped years
        append_comma_clause(opts.range, opts.post_pat)
        update_range_clause(opts.range, opts.post_pat)
        if options.style.advanced.force then
            update_comma_clauses(opts.range, opts.post_pat)
        end
    elseif options.style.kind == 'simple' then
        if options.style.simple.force then
            -- Collapse advanced copyright lines to simple ones
            collapse_to_range_clause(opts.range, opts.post_pat)
        else
            -- Update only simple lines
            update_range_clause(opts.range, opts.post_pat)
        end
    else
        vim.api.nvim_err_writeln('copyright-updater.nvim unknown option value for style.kind')
    end

    -- Restore cursor position
    if options.return_cursor then vim.fn.winrestview(position) end

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
    assert(type(options.style.advanced) == "table", "Option 'style.advanced' must be a table")
    assert(type(options.style.advanced.space_after_comma) == "boolean", "Option 'style.advanced.space_after_comma' must be either true or false")

    -- mappings
    assert(type(options.mappings) == "table", "Option 'mappings' must be a table")
    assert(type(options.mappings.toggle) == "string" or type(options.mappings.toggle) == "nil", "Option 'mappings.toggle' must be a string or nil")
    assert(type(options.mappings.update) == "string" or type(options.mappings.update) == "nil", "Option 'mappings.update' must be a string or nil")
    assert(type(options.mappings.enable) == "string" or type(options.mappings.enable) == "nil", "Option 'mappings.enable' must be a string or nil")
    assert(type(options.mappings.disable) == "string" or type(options.mappings.disable) == "nil", "Option 'mappings.disable' must be a string or nil")

    -- limiters
    assert(type(options.limiters) == "table", "Option 'limiters' must be a table")
    assert(type(options.limiters.range) == "string", "Option 'limiters.range' must be a string")
    assert(type(options.limiters.post_pattern) == "string", "Option 'limiters.post_pattern' must be a table")
    assert(type(options.limiters.files) == "table", "Option 'limiters.files' must be a table")
    assert(type(options.limiters.files.types) == "table", "Option 'limiters.files.types' must be a table")
    assert(type(options.limiters.files.names) == "table", "Option 'limiters.files.names' must be a table")
    assert(type(options.limiters.files.type_whitelist) == "boolean", "Option 'limiters.files.type_whitelist' must be either true or false")
    assert(type(options.limiters.files.name_whitelist) == "boolean", "Option 'limiters.files.name_whitelist' must be either true or false")

    for i,_ in pairs(options.limiters.files.types) do
        assert(type(options.limiters.files.types[i]) == "string", "Entries in option table 'limiters.files.types' must be of type string")
    end
    for i,_ in pairs(options.limiters.files.names) do
        assert(type(options.limiters.files.names[i]) == "string", "Entries in option table 'limiters.files.names' must be of type string")
    end
end

local function user_cmd_UpdateCopyright(opts)
    local update_args = {force = opts.bang}

    if opts.args ~= "" then
        update_args.post_pat = opts.args
    elseif opts.bang then
        update_args.post_pat = ''
    end

    if opts.range == 2 then
        update_args.range = opts.line1 .. ',' .. opts.line2
    elseif opts.range == 1 then
        update_args.range = opts.line1
    elseif opts.bang then
        update_args.range = '%'
    end

    M.update(update_args)
end

function M.setup(config)
    options = vim.tbl_deep_extend('force', options, config or {})

    verify_options()

    -- escape colons - they are used at pattern delimiters internally
    if options.limiters.post_pattern ~= '' then
        options.limiters.post_pattern = string.gsub(options.limiters.post_pattern, ':', '\\:')
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
        vim.api.nvim_set_keymap('n', options.mappings.update, '<cmd>lua require("copyright-updater").update()<CR>', {noremap=true, silent=true, desc='Update Copyrights'})
    end

    vim.api.nvim_create_augroup("copyright_updater", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
        desc = "Update Copyright",
        group = "copyright_updater",
        pattern = "*",
        callback = function() M.update() end
    })

    vim.api.nvim_create_user_command(
        'UpdateCopyright',
        function(opts) user_cmd_UpdateCopyright(opts) end,
        {bang=true,range=true,nargs='?'}
    )
end

return M
