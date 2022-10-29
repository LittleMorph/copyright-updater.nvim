local copyright_updater = require("copyright-updater")
describe("copyright_updater", function()
    for _, setup in ipairs {
        {
            name = 'advanced',
            style = { kind = 'advanced' }
        },{
            name = 'advanced',
            style = { kind = 'advanced', advanced = { force = true } }
        },{
            name = 'simple',
            style = { kind = 'simple', simple = { force = false } }
        },{
            name = 'forced simple',
            style = { kind = 'simple', simple = { force = true } }
        }
    } do
        describe(":UpdateCopyright (" .. setup.name .. " style)", function()
            after_each(function()
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            end)

            it("should work with a post pattern", function()
                copyright_updater.setup({
                    silent = true,
                    style = setup.style,
                    limiters = { post_pattern = "Corp A/S" }
                })
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar",
                })
                vim.cmd(":UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                    "# Copyright © 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar",
                })
            end)

            it("should work with another post pattern", function()
                copyright_updater.setup({
                    silent = true,
                    style = setup.style,
                    limiters = { post_pattern = "New Org Inc." }
                })
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar",
                })
                vim.cmd(":UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright © 2018-" .. os.date("%Y") .. " New Org Inc.",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar",
                })
            end)

            it("should work with a post pattern regex", function()
                copyright_updater.setup({
                    silent = true,
                    style = setup.style,
                    limiters = { post_pattern = "\\%(Corp A/S\\|New Org Inc.\\)" }
                })
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S, All rights reserved",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S Trailing",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " New Org Inc., All rights reserved",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " New Org Inc. Trailing",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar, All rights reserved",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar Trailing",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar",
                })
                vim.cmd(":UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S, All rights reserved",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S Trailing",
                    "# Copyright © 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " New Org Inc., All rights reserved",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " New Org Inc. Trailing",
                    "# Copyright © 2018-" .. os.date("%Y") .. " New Org Inc.",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar, All rights reserved",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar Trailing",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar",
                })
            end)

            it("should work with a post pattern regex followed by more characters", function()
                copyright_updater.setup({
                    silent = true,
                    style = setup.style,
                    limiters = { post_pattern = "\\%(Corp A/S\\|New Org Inc.\\).*" }
                })
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S, All rights reserved",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S Trailing",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " New Org Inc., All rights reserved",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " New Org Inc. Trailing",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " New Org Inc.",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar, All rights reserved",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar Trailing",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar",
                })
                vim.cmd(":UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                    "# Copyright © 2018-" .. os.date("%Y") .. " Corp A/S, All rights reserved",
                    "# Copyright © 2018-" .. os.date("%Y") .. " Corp A/S Trailing",
                    "# Copyright © 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright © 2018-" .. os.date("%Y") .. " New Org Inc., All rights reserved",
                    "# Copyright © 2018-" .. os.date("%Y") .. " New Org Inc. Trailing",
                    "# Copyright © 2018-" .. os.date("%Y") .. " New Org Inc.",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar, All rights reserved",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar Trailing",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Foobar",
                })
            end)
        end)
    end
end)
