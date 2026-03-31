---@type vim.lsp.Config
return {
  ---@type lspconfig.settings.lua_ls
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
