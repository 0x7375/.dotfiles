---@type vim.lsp.Config
return {
  ---@type lspconfig.settings.intelephense
  capabilities = {
    documentFormattingProvider = true,
  },
  settings = {
    intelephense = {
      format = { enable = true, braces = "k&r" },
    },
  },
}
