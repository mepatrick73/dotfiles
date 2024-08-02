function PrintLspSettings()
    local clients = vim.lsp.buf_get_clients()
    for client_id, client in pairs(clients) do
        print("LSP Client: " .. client.name)
        print(vim.inspect(client.config.settings))
    end
end

vim.cmd('command! LspSettings lua PrintLspSettings()')
