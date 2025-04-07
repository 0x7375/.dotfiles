InCodium = vim.g.vscode ~= nil

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.termguicolors = true

local opts = {
    change_detection = {
        notify = false,
    },
    ui = {
        border = "single",
        backdrop = 100,
    },
    dev = {
        path = "~/repos",
    },
    performance = {
        rtp = {
            disabled_plugins = {
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
                -- "man",
                "matchparen",
                "tar",
                "tarPlugin",
                "rrhelper",
                "vimball",
                "health",
                "shada",
                "spellfile",
                "tohtml",
                "tutor",
                "vimballPlugin",
                "zip",
                "zipPlugin",
                "rplugin",
            },
        },
    },
}
require("opts")
require("keymaps")
if not InCodium then
    require("lazy").setup({
        { import = 'plugins.nav' },
        { import = 'plugins.lsp' },
        { import = 'plugins.actions' },
        { import = 'plugins.tools' },
        { import = 'plugins.ui' },
    }, opts)
    require("autocmds")
else
    require("lazy").setup('plugins.actions', opts)
    require("codium")
end
