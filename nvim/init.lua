vim.loader.enable()

_G.map = vim.keymap.set
_G.del = vim.keymap.del

-- automatically append github to entries without an absolute source
_G.pack = function(plugins, opts)
  for k, p in ipairs(plugins) do
    if type(p) == "string" and not p:match("^https?://") then
      plugins[k] = "https://github.com/" .. p
    elseif type(p) == "table" and p.src and not p.src:match("^https?://") then
      p.src = "https://github.com/" .. p.src
    end
  end
  vim.pack.add(plugins, opts)
end

_G.on_event = function(ev, f)
  vim.api.nvim_create_autocmd(vim.split(ev, ","), {
    callback = function() pcall(f) end,
  })
end

_G.on_filetype = function(ft, f)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = vim.split(ft, ","),
    callback = function() pcall(f) end,
  })
end

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
