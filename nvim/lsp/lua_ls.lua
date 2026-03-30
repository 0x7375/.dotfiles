---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      format = { enable = false }, -- using stylua
      hint = {
        enable = true,
        arrayIndex = "Disable",
      },
    },
  },
}
