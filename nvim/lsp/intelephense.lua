---@type vim.lsp.Config
return {
  on_init = function(client) client.server_capabilities.documentFormattingProvider = true end,
  settings = {
    intelephense = {
      format = { enable = true, braces = "k&r" },
    },
  },
}
