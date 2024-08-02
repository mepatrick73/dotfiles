return {
    "nvim-tree/nvim-tree.lua",
    config = function()
        require("nvim-tree").setup {
            view = {
                side = "right"
            }
        }
        vim.keymap.set("n", "<C-t>", function() vim.cmd("NvimTreeToggle") end)
        vim.keymap.set("n", "<leader>n", function() vim.cmd("NvimTreeFocus") end)
    end
}
