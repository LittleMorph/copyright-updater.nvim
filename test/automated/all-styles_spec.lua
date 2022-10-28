local copyright_updater = require("copyright-updater")
describe("copyright_updater", function()
    for _, setup in ipairs {
        { name = 'advanced', style = { kind = 'advanced' } },
        { name = 'simple', style = { kind = 'simple', simple = { force = false } } },
        { name = 'forced simple', style = { kind = 'simple', simple = { force = true } } }
    } do
        describe(":UpdateCopyright (" .. setup.name .. " style)", function()

            before_each(function()
                copyright_updater.setup({
                    silent = true,
                    style = setup.style
                })
            end)

            after_each(function()
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            end)

            it("should match with all three copyright symbols: (c), ©, &copy;", function()
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright (c) 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright &copy; 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                })
                vim.cmd(":UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                    "# Copyright (c) 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright © 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright &copy; 2018-" .. os.date("%Y") .. " Corp A/S"
                })
            end)

            it("should handle any leading characters", function()
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright (c) 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "#Copyright (c) 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "Copyright &copy; 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "-- Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "--Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "* Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "/* Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "; Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "This work is Copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                })
                vim.cmd(":UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                    "# Copyright (c) 2018-" .. os.date("%Y") .. " Corp A/S",
                    "#Copyright (c) 2018-" .. os.date("%Y") .. " Corp A/S",
                    "Copyright &copy; 2018-" .. os.date("%Y") .. " Corp A/S",
                    "-- Copyright © 2018-" .. os.date("%Y") .. " Corp A/S",
                    "--Copyright © 2018-" .. os.date("%Y") .. " Corp A/S",
                    "* Copyright © 2018-" .. os.date("%Y") .. " Corp A/S",
                    "/* Copyright © 2018-" .. os.date("%Y") .. " Corp A/S",
                    "; Copyright © 2018-" .. os.date("%Y") .. " Corp A/S",
                    "This work is Copyright © 2018-" .. os.date("%Y") .. " Corp A/S",
                })
            end)

            it("should handle any trailing characters", function()
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright (c) 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright © 2018-" .. os.date("%Y") - 1 .. "",
                    "# Copyright &copy; 2018-" .. os.date("%Y") - 1 .. "Corp A/S"
                })
                vim.cmd(":UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                    "# Copyright (c) 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright © 2018-" .. os.date("%Y"),
                    "# Copyright &copy; 2018-" .. os.date("%Y") .. "Corp A/S"
                })
            end)

            it("should not care about spaces around copyright symbol", function()
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright(c)2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright©2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright&copy;2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright   (c)   2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright   ©   2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright   &copy;   2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                })
                vim.cmd(":UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                    "# Copyright(c)2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright©2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright&copy;2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright   (c)   2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright   ©   2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright   &copy;   2018-" .. os.date("%Y") .. " Corp A/S"
                })
            end)

            it("should not care if the copyright symbol is missing", function()
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright    2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# Copyright2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                })
                vim.cmd(":UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                    "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright    2018-" .. os.date("%Y") .. " Corp A/S",
                    "# Copyright2018-" .. os.date("%Y") .. " Corp A/S",
                })
            end)

            it("should not care about the casing of copyright", function()
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    "# COPYRIGHT (c) 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# copyright © 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# CoPyRiGhT &copy; 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    "# CopyRight 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                })
                vim.cmd(":UpdateCopyright")
                assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                    "# COPYRIGHT (c) 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# copyright © 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# CoPyRiGhT &copy; 2018-" .. os.date("%Y") .. " Corp A/S",
                    "# CopyRight 2018-" .. os.date("%Y") .. " Corp A/S"
                })
            end)
        end)
    end
end)
