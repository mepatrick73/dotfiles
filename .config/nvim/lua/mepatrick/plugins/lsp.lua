return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "j-hui/fidget.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
    },
    config = function()
        local on_attach = function(_, bufnr)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
            vim.keymap.set("n", "<leader>ca", function()
                vim.lsp.buf.code_action({ context = { only = { "quickfix", "refactor", "source" } } })
            end)

            vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions)
            vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references)
            vim.keymap.set("n", "gI", require("telescope.builtin").lsp_implementations)
            vim.keymap.set("n", "<leader>D", require("telescope.builtin").lsp_type_definitions)
            vim.keymap.set("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols)
            vim.keymap.set("n", "<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols)
            vim.keymap.set("n", "<leader>dj", vim.diagnostic.goto_next)
            vim.keymap.set("n", "<leader>dk", vim.diagnostic.goto_prev)
            vim.keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>")

            vim.keymap.set("n", "K", vim.lsp.buf.hover)
            vim.keymap.set("i", "<C-;>", vim.lsp.buf.signature_help)
            -- Lesser used LSP functionality

            vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
            vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder)
            vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder)
            vim.keymap.set("n", "<leader>wl", function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end)

            -- Create a command `:Format` local to the LSP buffer
            vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
                vim.lsp.buf.format()
            end, { desc = "Format current buffer with LSP" })
        end
        local cmp = require("cmp")
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )
        local luasnip = require("luasnip")
        require("fidget").setup({})
        require("mason").setup({})
        require("mason-tool-installer").setup({
            ensure_installed = {
                "ruff",
                "mypy",
                "eslint_d",
                "stylua",
                "prettierd",
                "autopep8",
                "clang-format",
            },
        })
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "wgsl_analyzer",
                "tsserver",
                "pyright",
                "clangd",
                "taplo",
            },
            handlers = {
                function(server_name) -- default handler
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                                },
                            },
                        },
                    })
                end,
                ["clangd"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.clangd.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                end,
                ["rust_analyzer"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.rust_analyzer.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = {
                            ["rust-analyzer"] = {
                                cargo = {
                                    autoreload = true,
                                },
                                checkOnSave = {
                                    command = "clippy",
                                },
                                procMacro = {
                                    enable = true,
                                },
                            },
                        },
                        root_dir = function(fname)
                            return lspconfig.util.root_pattern("Cargo.toml")(fname) or lspconfig.util.path.dirname(fname)
                        end,
                    })
                end
            },
        })

        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete({}),
                ["<C-i>"] = cmp.mapping.confirm({ select = true }),
                ["<C-n>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-p>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
                --{ name = 'nvim_lsp_signature_help' },
                { name = "nvim_lsp" },
                { name = "luasnip" }, -- For luasnip users.
            }, {

                { name = "buffer" },
            }),
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end,
}
