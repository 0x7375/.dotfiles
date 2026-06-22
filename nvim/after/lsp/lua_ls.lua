---@type vim.lsp.Config
return {
  ---@type lspconfig.settings.lua_ls
  settings = {
    Lua = {
      diagnostics = { globals = { "map", "del", "pack", "on_event", "on_filetype" } },
      format = { enable = false }, -- using stylua
      hint = {
        enable = true,
        arrayIndex = "Disable",
      },
    },
  },
}
