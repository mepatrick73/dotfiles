return {
    "nvim-treesitter/nvim-treesitter",

    config = function ()
        require('nvim-treesitter.configs').setup {
            ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "typescript", "html", "css", "cpp", "rust", "java", "wgsl" },
            highlight = {
                enable = true
            }
        }
    end
}
