return {
    "vxpm/rust-expand-macro.nvim",
    config = function()
        vim.keymap.set("n", "<leader>me", function() require('rust-expand-macro').expand_macro() end)
    end
}
