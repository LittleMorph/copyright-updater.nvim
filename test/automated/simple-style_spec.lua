local copyright_updater = require("copyright-updater")
describe("copyright_updater", function()
    describe(":UpdateCopyright simple style", function()

        before_each(function()
            copyright_updater.setup({
                silent = true,
                style = {
                    kind = 'simple',
                    simple = {
                        force = false
                    }
                }
            })
        end)

        after_each(function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
        end)

        it("should leave commas alone", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-2019," .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018," .. os.date("%Y") - 2 .. " Corp A/S"
            })
            vim.cmd(":UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-2019," .. os.date("%Y") - 1 .. "-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018," .. os.date("%Y") - 2 .. "-" .. os.date("%Y") .. " Corp A/S"
            })
        end)

        it("should update or create range with the last year listed", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2019 Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 2 .. " Corp A/S",
                "# Copyright " .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright " .. os.date("%Y") .. " Corp A/S"
            })
            vim.cmd(":UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2019-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright " .. os.date("%Y") - 1 .. "-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright " .. os.date("%Y") .. " Corp A/S"
            })
        end)

        it("should not care that existing ranges go backwards in time", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# COPYRIGHT 2020,2018-2016 Corp A/S",
            })
            vim.cmd(":UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# COPYRIGHT 2020,2018-" .. os.date("%Y") .. " Corp A/S",
            })
        end)

        it("should not care if commas are followed by spaces", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# COPYRIGHT 2016,2018, 2020 Corp A/S",
            })
            vim.cmd(":UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# COPYRIGHT 2016,2018, 2020-" .. os.date("%Y") .. " Corp A/S",
            })
        end)
    end)
end)

describe("copyright_updater", function()
    describe(":UpdateCopyright forced simple style", function()

        before_each(function()
            copyright_updater.setup({
                silent = true,
                style = {
                    kind = 'simple',
                    simple = {
                        force = true
                    }
                }
            })
        end)

        after_each(function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
        end)

        it("should compress existing rantes and lists to a single range", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2019 Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 2 .. " Corp A/S",
                "# Copyright 2018," .. os.date("%Y") - 2 .. " Corp A/S",
                "# Copyright 2018," .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-2019," .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright " .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2016,   2018  ,  2020, " .. os.date("%Y") .. " Corp A/S"
            })
            vim.cmd(":UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2019-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright " .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2016-" .. os.date("%Y") .. " Corp A/S"
            })
        end)

        it("should not care that existing ranges go backwards in time", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "# COPYRIGHT 2020,2018-2016 Corp A/S",
            })
            vim.cmd(":UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# COPYRIGHT 2020-" .. os.date("%Y") .. " Corp A/S",
            })
        end)
    end)
end)
