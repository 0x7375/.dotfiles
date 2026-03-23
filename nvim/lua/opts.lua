-- disable # indenting weird behaviour
vim.opt.cindent = true
vim.opt.cinkeys:remove("0#")
vim.opt.indentkeys:remove("0#")

vim.opt.modeline = false

vim.opt.winborder = "single";
vim.opt.pumheight = 8
vim.opt.pummaxwidth = 60
vim.opt.pumborder = "single"
vim.opt.completeopt = { "menu", "menuone", "popup", "nearest" }

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- hide search hit bottom
vim.opt.shortmess:append("Is")

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.showmode = false

vim.opt.ignorecase = true -- ignore case in search patterns
vim.opt.smartcase = true  -- smart case

vim.opt.conceallevel = 0

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.updatetime = 50
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.numberwidth = 2
vim.opt.signcolumn = "yes"

vim.opt.scrolloff = 8

-- allow @ inside filename
vim.opt.isfname:append("@-@")

vim.opt.breakindent = true
vim.opt.linebreak = true

-- split windows
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.belloff = "all"

vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.foldcolumn = "0"
vim.opt.foldmethod = "indent"

vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 10

-- Use ripgrep for grepping.
vim.opt.grepprg = 'rg --vimgrep'
vim.opt.grepformat = '%f:%l:%c:%m'

-- Number of recent files
vim.opt.shada = "!,'1000,<50,s10,h,:10000"

-- Block in insert mode
vim.opt.guicursor = ""
vim.opt.cursorline = true

-- fix ^^ chars in statusline
-- vim.opt.fillchars:append("stl: ,stlnc: ")

require("util.bar").init()

vim.opt.laststatus = 0
vim.opt.cmdheight = 0

vim.cmd("set statusline=%{repeat('─',winwidth('.'))}")

if os.getenv("SSH_TTY") ~= nil then
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    },
    cache_enabled = 0,
  }
else
  vim.g.clipboard = {
    name = 'wl-clipboard',
    copy = {
      ['+'] = 'wl-copy',
    },
    paste = {
      ['+'] = { 'wl-paste', '--no-newline' },
    },
    cache_enabled = 0,
  }
end
