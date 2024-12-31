return {
    "stevearc/conform.nvim",
    config = function()
        local conform = require("conform")

        require("conform").setup({
            formatters_by_ft = {
                python = { "autopep8" },
                javascript = { { "prettierd", "prettier" } },
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout = 500,
            },
        })

        vim.keymap.set({ "n", "v" }, "<leader>fm", function()
            conform.format({
                lsp_fallbacl = true,
                async = false,
                timeout = 500,
            })
        end, { desc = "Format selected text or current file" })
    end,
}
