local copyright_updater = require("copyright-updater")
describe("copyright_updater", function()
    for _, setup in pairs {
        {
            range = '2,4',
            result = {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            }
        },{
            range  = '3,$',
            result = {
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S"
            }
        },{
            range = '', -- Updates only the current line
            result = {
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            }
        },{
            range = '1,3',
            result = {
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
            }
        }
    } do
        for _, config in ipairs {
            {
                name = 'advanced',
                config = {
                    silent = true,
                    style = { kind = 'advanced' },
                    limiters = { range = setup.range }
                }
            },{
                name = 'simple',
                config = {
                    silent = true,
                    style = { kind = 'simple', simple = { force = false } },
                    limiters = { range = setup.range }
                }
            },{
                name = 'forced simple',
                config = {
                    silent = true,
                    style = { kind = 'simple', simple = { force = true } },
                    limiters = { range = setup.range }
                }
            }
        } do
            describe(":UpdateCopyright (" .. config.name .. " style)", function()

                before_each(function()
                    copyright_updater.setup(config.config)
                end)

                after_each(function()
                    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
                end)

                it("should update the correct lines (range: '" .. setup.range .. "')", function()
                    vim .api.nvim_buf_set_lines(0, 0, -1, false, {
                        "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                        "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                        "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                        "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                        "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"
                    })
                    vim.cmd(":UpdateCopyright")
                    assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), setup.result)
                end)
            end)
        end
    end
end)
