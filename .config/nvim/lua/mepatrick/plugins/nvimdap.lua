return {
    "mfussenegger/nvim-dap",
    config = function()
        vim.keymap.set('n', '<Leader>bp', function() require('dap').toggle_breakpoint() end)
        vim.keymap.set('n', '<F1>', function() require('dap').step_over() end)
        vim.keymap.set('n', '<F2>', function() require('dap').step_into() end)
        vim.keymap.set('n', '<F3>', function() require('dap').step_out() end)
        vim.keymap.set('n', '<F5>', function() require("dap").continue() end)
    end,
}
