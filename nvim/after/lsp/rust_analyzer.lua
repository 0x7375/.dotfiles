---@type vim.lsp.Config
return {
  settings = {
    ["rust-analyzer"] = {
      diagnostics = { enable = false },
      check = { command = "clippy" },
    },
  },
}
