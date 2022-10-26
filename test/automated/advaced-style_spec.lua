local copyright_updater = require("copyright-updater")
describe("copyright_updater", function()
    describe(":UpdateCopyright advanced style", function()

        before_each(function()
            copyright_updater.setup({
                silent = true,
                style = {
                    advanced = true,
                    force = false
                }
            })
        end)

        after_each(function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
        end)

        it("should add commas when last recorded year is not last year", function()
            vim .api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 2 .. " Corp A/S",
                "# Copyright " .. os.date("%Y") - 2 .. " Corp A/S",
                "# Copyright 2019-2018," .. os.date("%Y") - 2 .. " Corp A/S",
                "# Copyright 2019 Corp A/S",
                "# Copyright 2018-2020 Corp A/S",
                "# Copyright " .. os.date("%Y") .. " Corp A/S"
            })
            vim.cmd(":UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") - 2 .. "," .. os.date("%Y") .. " Corp A/S",
                "# Copyright " .. os.date("%Y") - 2 .. "," .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2019-2018," .. os.date("%Y") - 2 .. "," .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2019," .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-2020," .. os.date("%Y") .. " Corp A/S",
                "# Copyright " .. os.date("%Y") .. " Corp A/S"
            })
        end)

        it("should add or update range when last recorded year is last year", function()
            vim .api.nvim_buf_set_lines(0, 0, -1, false, {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright " .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2019-2018," .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright " .. os.date("%Y") .. " Corp A/S"
            })
            vim.cmd(":UpdateCopyright")
            assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright " .. os.date("%Y") - 1 .. "-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2019-2018," .. os.date("%Y") - 1 .. "-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright " .. os.date("%Y") .. " Corp A/S"
            })
        end)
    end)
end)
