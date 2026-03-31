local bar = require("util.bar")

map({ "n", "x", "v" }, ":", ";")
map({ "n", "x", "v" }, ";", ":")

-- Don't leave visual after indent
map("x", "<", "<gv")
map("x", ">", ">gv")

-- Remap U to redo
map("n", "<S-u>", "<C-r>")

-- ! for shell command
map("n", "!", ":!", { silent = false })

-- Unbind space outside of insert
map({ "n", "v" }, "<space>", "<nop>")

map({ "n", "x" }, "s", "V")

map("n", "<ESC>", function()
  vim.cmd("nohlsearch")
  bar.refresh()
end, { desc = "Clear search highlights" })

-- easy renaming
map("n", "<leader>r", [[:%s/\v<<C-r><C-w>>/<C-r><C-w>/gI<Left><Left><Left>]])

local function toggle_quickfix()
  local windows = vim.fn.getwininfo()
  for _, win in pairs(windows) do
    if win["quickfix"] == 1 then
      vim.cmd.cclose()
      return
    end
  end
  vim.cmd.copen()
end

map("n", "<leader>q", toggle_quickfix, { desc = "Toggle quickfix window" })
map("n", "<C-n>", vim.cmd.cnext, { desc = "Next quickfix" })
map("n", "<C-p>", vim.cmd.cprevious, { desc = "Previous quickfix" })

-- Center on movement
map("n", "<C-d>", "<C-d>zz", { noremap = true })
map("n", "<C-u>", "<C-u>zz", { noremap = true })
map("n", "<C-b>", "<C-b>zz", { noremap = true })
map("n", "<C-f>", "<C-f>zz", { noremap = true })
map("n", "*", "*zz", { noremap = true })
map("n", "#", "#zz", { noremap = true })

map("n", "n", function()
  vim.cmd("normal! nzz")
  bar.refresh()
end)

vim.keymap.set("n", "N", function()
  vim.cmd("normal! Nzz")
  bar.refresh()
end)

map("n", "G", "Gzz", { noremap = true })
map("n", "}", "}zz", { noremap = true })
map("n", "{", "{zz", { noremap = true })

map("n", "<C-o>", "<C-o>zz", { noremap = true })
map("n", "<C-i>", "<C-i>zz", { noremap = true })

map("n", "<leader>s", ":%s#", { noremap = true })
map("n", "<leader>S", ":%g#", { noremap = true })

vim.keymap.set("c", "<CR>", function()
  local cmdtype = vim.fn.getcmdtype()
  -- center and refresh winbar on search commands
  if cmdtype == "/" or cmdtype == "?" then
    return '<CR>zz<Cmd>lua require("util.bar").refresh()<CR>'
  else
    return "<CR>"
  end
end, { expr = true })

map("i", "<Esc>", function() return vim.fn.pumvisible() == 1 and "<C-e>" or "<Esc>" end, { expr = true })

-- Makes the file executable
map("n", "<leader>xm", function() vim.cmd("!chmod +x %") end, { silent = true, desc = "Make file executable" })

-- Alternate file (silent, no error if no alternate file)
vim.keymap.set("n", "<S-Tab>", "<Cmd>silent! b #<CR>zz", { desc = "Alternate file" })

-- Indent whole file
map("n", "<leader>=", "mzgg=G`zzz", { desc = "Indent whole file" })

-- map({ 'n', 'x' }, 'go', function() vim.cmd("silent !xdg-open <cfile> &") end,
--     { desc = "Open file in default program" })

-- toggle line wrap
map("n", "<leader>l", function() vim.cmd("set wrap!") end, { desc = "Toggle line wrap" })

map("n", "<C-w>Q", function() vim.cmd("qa") end, { desc = "Quit all" })

-- insert and command line emacs keybinds
-- cmdline
map("c", "<C-a>", "<Home>")
map("c", "<C-e>", "<End>")
map("c", "<C-k>", "<C-f>D<C-c><C-c>:<Up>")
map("c", "<A-b>", "<C-Left>")
map("c", "<A-f>", "<C-Right>")
map("c", "<A-d>", "<C-Right><C-w>")
map("c", "<C-h>", "<BS>")
map("c", "<C-d>", "<Del>")
map("c", "<C-f>", "<Right>")
map("c", "<C-b>", "<Left>")

-- direction based window resizing
local change_width = function(d)
  local v = vim.api

  d = d and d or "left"
  local lr = d == "left" or d == "right"
  -- 5 for left right, 3 for up down
  local amt = lr and 5 or 3

  local pos = v.nvim_win_get_position(0)
  local w = v.nvim_win_get_width(0)
  local h = v.nvim_win_get_height(0)

  if lr then
    amt = pos[2] == 0 and -amt or amt
  else
    amt = pos[1] == 0 and -amt or amt
  end

  w = (d == "left") and (w + amt) or (w - amt)
  h = (d == "up") and (h + amt) or (h - amt)

  if lr then
    v.nvim_win_set_width(0, w)
  else
    v.nvim_win_set_height(0, h)
  end
end

-- add go to jumplist
map("n", "go", "m'go")

map("n", "<M-h>", function() change_width("left") end, { desc = "Resize window left" })
map("n", "<M-l>", function() change_width("right") end, { desc = "Resize window right" })
map("n", "<M-k>", function() change_width("up") end, { desc = "Resize window up" })
map("n", "<M-j>", function() change_width("down") end, { desc = "Resize window down" })

map({ "x", "n" }, "+", '"+', { desc = "+ for system clipboard register" })
map({ "x", "n" }, "_", '"_', { desc = "_ for void register" })
map("x", "P", "pgv=", { desc = "Paste and indent in visual mode" })
map("n", "gp", "`[v`]", { desc = "Select last pasted text" })
map("n", "<leader>y", 'goVG"+y', { desc = "Copy entire file content" })

map("n", "<leader>'", vim.cmd.Lazy, { desc = "Open Lazy UI" })

map("n", "<leader>xl", ":.lua<CR>", { desc = "Run current line with lua" })
map("x", "<leader>xl", ":lua<CR>", { desc = "Run visual selection with lua" })

map("n", "<leader>N", vim.cmd.restart, { desc = "Restart neovim" })

map("n", '<leader>"', function()
  local buf = vim.api.nvim_create_buf(false, true)

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "single",
  })

  for name, value in pairs({
    filetype = "scratch",
    buftype = "nofile",
    bufhidden = "wipe",
    swapfile = false,
    modifiable = true,
  }) do
    vim.api.nvim_set_option_value(name, value, { buf = buf })
  end
end, { desc = "Open a scratch buffer" })
