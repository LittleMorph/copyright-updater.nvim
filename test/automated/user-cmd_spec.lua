local copyright_updater = require("copyright-updater")
describe("copyright_updater", function()
    describe(":UpdateCopyright", function()

        copyright_updater.setup({
            limiters = {
                range = '1,3',
                files = {
                    type_whitelist = false,
                    types = {
                        'lua',
                        'markdown',
                    }
                }
            }
        })

        after_each(function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
        end)

        it("should ignore file type limiters when called with bang", function()
            vim.bo.filetype = 'lua'
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
            vim.cmd("UpdateCopyright!")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S"
            })
        end)

        it("should not ignore file type limiters when called without bang", function()
            vim.bo.filetype = 'lua'
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
            vim.cmd("UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
        end)

        it("should override the range limiter (multiline - with bang)", function()
            vim.bo.filetype = 'lua'
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
            vim.cmd("1,3UpdateCopyright!")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
        end)

        it("should override the range limiter (multiline - without bang)", function()
            vim.bo.filetype = 'vim'
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
            vim.cmd("1,3UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
        end)

        it("should override the range limiter (multiline - without bang) - but respect file limiters", function()
            vim.bo.filetype = 'lua'
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
            vim.cmd("1,3UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
        end)

        it("should override the range limiter (single line - with bang)", function()
            vim.bo.filetype = 'lua'
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
            vim.cmd("3UpdateCopyright!")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
        end)

        it("should override the range limiter (single line - without bang)", function()
            vim.bo.filetype = 'vim'
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
            vim.cmd("3UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
        end)

        it("should override the range limiter (single line - without bang) - but respect file limiters", function()
            vim.bo.filetype = 'lua'
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
            vim.cmd("3UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            })
        end)

        it("should override post_pattern (with bang)", function()
            vim.bo.filetype = 'lua'
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc."
            })
            vim.cmd("2,$UpdateCopyright! New Org Inc.")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") .. " New Org Inc."
            })
        end)

        it("should override post_pattern (without bang)", function()
            vim.bo.filetype = 'vim'
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc."
            })
            vim.cmd("3UpdateCopyright New Org Inc.")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc."
            })
        end)

        it("should override post_pattern (without bang) - but respect file limiters", function()
            vim.bo.filetype = 'lua'
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc."
            })
            vim.cmd("3UpdateCopyright New Org Inc.")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " New Org Inc."
            })
        end)
    end)
end)
