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
                    files = {
                        name_whitelist = whitelist,
                        names = {
                            '/test-dir/',
                            '/init\\.lua',
                            '/lua[^/]*$',
                            '/colon:colon/'
                        }
                    }
                }
            })

            for _, setup in pairs {
                { in_pattern = true,  name = '/home/user/git/projects/foobar/test-dir/some-file.lua'},
                { in_pattern = true,  name = '/home/user/git/projects/foobar/test-dir/Makefile'},
                { in_pattern = false, name = '/home/user/git/projects/foobar/doc/README.md'},
                { in_pattern = true,  name = '/home/user/git/projects/foobar/lua/init.lua'},
                { in_pattern = false, name = '/home/user/git/projects/foobar/lua/foobar.lua'},
                { in_pattern = true,  name = '/home/user/git/projects/foobar/src/luafile.lua'},
                { in_pattern = true,  name = '/home/user/git/projects/foobar/colon:colon/luafile.lua'},
            } do

                local desc
                if whitelist then
                    desc = "should match file name patterns in whitelist mode"
                else
                    desc = "should not match file name patterns in blackslist mode"
                end

                it(desc, function()
                    vim.api.nvim_buf_set_name(0, setup.name)
                    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                        "# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S",
                    })

                    vim.cmd(":UpdateCopyright")

                    local lines = {}
                    if (whitelist and setup.in_pattern) or (not whitelist and not setup.in_pattern) then
                        lines = {"# Copyright 2018-" .. os.date("%Y") .. " Corp A/S"}
                    else
                        lines = {"# Copyright 2018-" .. os.date("%Y") - 1 .. " Corp A/S"}
                    end
                    assert.same(vim.api.nvim_buf_get_lines(0, 0, -1, false), lines)
                end)
            end
        end)
    end
end)
