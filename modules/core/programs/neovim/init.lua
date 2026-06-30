vim.loader.enable()

_G.map = vim.keymap.set
_G.del = vim.keymap.del

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.termguicolors = true

local disabled_builtins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  -- "matchparen",
  "tar",
  "tarPlugin",
  "rrhelper",
  "vimball",
  "vimballPlugin",
  "health",
  "shada",
  "spellfile",
  "tohtml",
  "tutor",
  "vimballPlugin",
  "zip",
  "zipPlugin",
  "rplugin",
}

for _, plugin in ipairs(disabled_builtins) do
  vim.g["loaded_" .. plugin] = 1
end

if vim.fn.has("win32") == 1 then
  vim.g.windows = 1
end

require("opts")
require("keymaps")

if vim.g.vscode then
  require("codium")
  return
end

require("autocmds")

require("util.theme").update()
