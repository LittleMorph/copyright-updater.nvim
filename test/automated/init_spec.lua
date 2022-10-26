local copyright_updater = require("copyright-updater")
describe("copyright_updater", function()
    describe("setup", function()
        after_each(function()
            -- Delete all userdefined commands
            vim.cmd("silent! comclear")
        end)
        it("should define the :UpdateCopyright command", function()
            copyright_updater.setup()
            assert.truthy(vim.fn.exists(":UpdateCopyright") > 0)
        end)
        it("should not have defined the command :UpdateCopyright", function()
            assert.truthy(vim.fn.exists(":UpdateCopyright") == 0)
        end)
        it("should define the autocommand", function()
            assert.truthy(vim.fn.exists("#copyright_updater#BufWritePre#*") > 0)
        end)
        it("should define the default keymap", function()
            assert.equal(vim.fn.tolower(vim.fn.maparg('<leader>C', 'n')),'<cmd>lua require("copyright-updater").toggle()<cr>')
        end)
        it("should define custom keymaps", function()
            copyright_updater.setup({
                mappings = {
                    toggle = '<leader>CC',
                    enable = '<leader>CE',
                    disable = '<leader>CD',
                    update = '<leader>CU',
                },
            })
            assert.equal(vim.fn.tolower(vim.fn.maparg('<leader>CC', 'n')),'<cmd>lua require("copyright-updater").toggle()<cr>')
            assert.equal(vim.fn.tolower(vim.fn.maparg('<leader>CE', 'n')),'<cmd>lua require("copyright-updater").enable()<cr>')
            assert.equal(vim.fn.tolower(vim.fn.maparg('<leader>CD', 'n')),'<cmd>lua require("copyright-updater").disable()<cr>')
            assert.equal(vim.fn.tolower(vim.fn.maparg('<leader>CU', 'n')),'<cmd>lua require("copyright-updater").update(true)<cr>')
        end)
    end)
end)
