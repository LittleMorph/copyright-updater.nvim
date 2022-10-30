local copyright_updater = require("copyright-updater")
    describe("copyright_updater", function()
        for _, whitelist in ipairs {false, true} do
            describe(":UpdateCopyright", function()

            after_each(function()
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            end)

            copyright_updater.setup({
                silent = true,
                limiters = {
                    range = '1,3',
                    files = {
                        type_whitelist = whitelist,
                        types = {
                            'lua',
                            'markdown',
                        }
                    }
                }
            })

            local desc
            local lines
            if whitelist then
                desc = "should not match file type '' in whitelist mode"
                lines = {
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                }
            else
                desc = "should match file type '' in blacklist mode"
                lines = {
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                }
            end
            it(desc, function()
                vim.bo.filetype = ''
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                })
                vim.cmd("UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), lines)
            end)

            if whitelist then
                desc = "should not match file type 'vim' in whitelist mode"
                lines = {
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                }
            else
                desc = "should match file type 'vim' in blacklist mode"
                lines = {
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                }
            end
            it(desc, function()
                vim.bo.filetype = 'vim'
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                })
                vim.cmd("UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), lines)
            end)

            if whitelist then
                desc = "should match file type 'lua' in whitelist mode"
                lines = {
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                }
            else
                desc = "should not match file type 'lua' in blacklist mode"
                lines = {
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                }
            end
            it(desc, function()
                vim.bo.filetype = 'lua'
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                })
                vim.cmd("UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), lines)
            end)

            if whitelist then
                desc = "should match file type 'markdown' in whitelist mode"
                lines = {
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                }
            else
                desc = "should not match file type 'markdown' in blacklist mode"
                lines = {
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                }
            end
            it(desc, function()
                vim.bo.filetype = 'markdown'
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                })
                vim.cmd("UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), lines)
            end)
        end)
    end
end)
