return {
    -- List of plugins
    {
        "sainnhe/gruvbox-material",
        priority = 1000,
        config = function()
            -- Enable true colors if supported
            if vim.fn.has("termguicolors") == 1 then
                vim.o.termguicolors = true
            end

            -- Set background to dark
            vim.o.background = "dark"

            -- Configure Gruvbox Material
            vim.g.gruvbox_material_background = 'medium'
            vim.g.gruvbox_material_better_performance = 1

            -- Load the colorscheme
            vim.cmd('colorscheme gruvbox-material')

            -- Configure lightline colorscheme
            vim.g.lightline = { colorscheme = 'gruvbox_material' }
        end
    }
}
