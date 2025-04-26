-- Don't leave visual after indent
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

-- Remap U to redo
vim.keymap.set("n", "<S-u>", "<C-r>")

-- ! for shell command
vim.keymap.set("n", "!", ":!", { silent = false })

-- Unbind space outside of insert
vim.keymap.set({ 'n', 'v' }, '<space>', '<nop>')

vim.keymap.set({ "n", "x" }, "s", "V")

vim.keymap.set("n", "<ESC>", vim.cmd.nohlsearch, { desc = "Clear search highlights" })

-- easy renaming
vim.keymap.set("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

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

vim.keymap.set("n", "<leader>q", toggle_quickfix, { desc = "Toggle quickfix window" })
vim.keymap.set("n", "<C-n>", vim.cmd.cnext, { desc = "Next quickfix" })
vim.keymap.set("n", "<C-p>", vim.cmd.cprevious, { desc = "Previous quickfix" })

-- Center on movement
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })
vim.keymap.set("n", "<C-b>", "<C-b>zz", { noremap = true })
vim.keymap.set("n", "<C-f>", "<C-f>zz", { noremap = true })
vim.keymap.set("n", "*", "*zz", { noremap = true })
vim.keymap.set("n", "#", "#zz", { noremap = true })
vim.keymap.set("n", "n", "nzz", { noremap = true })
vim.keymap.set("n", "N", "Nzz", { noremap = true })
vim.keymap.set("n", "G", "Gzz", { noremap = true })
vim.keymap.set("n", "}", "}zz", { noremap = true })
vim.keymap.set("n", "{", "{zz", { noremap = true })

vim.keymap.set("n", "<C-o>", "<C-o>zz", { noremap = true })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { noremap = true })
-- Center on first search
vim.cmd("cnoremap <silent><expr> <enter> index(['/', '?'], getcmdtype()) >= 0 ? '<enter>zz' : '<enter>'")

-- Move lines
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down" })
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up" })

-- Makes the file executable
vim.keymap.set("n", "<leader>xm", function() vim.cmd("!chmod +x %") end, { silent = true, desc = "Make file executable" })

-- Alternate file
vim.keymap.set("n", "<S-Tab>", "<C-^>", { desc = "Alternate file" })

-- Indent whole file
vim.keymap.set("n", "<leader>=", "mzgg=G`zzz", { desc = "Indent whole file" })

vim.keymap.set({ 'n', 'x' }, 'go', function() vim.cmd("silent !xdg-open <cfile> &") end,
    { desc = "Open file in default program" })

-- toggle line wrap
vim.keymap.set('n', '<leader>l', function() vim.cmd("set wrap!") end, { desc = "Toggle line wrap" })

-- insert and command line emacs keybinds
-- cmdline
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('c', '<C-k>', '<C-f>D<C-c><C-c>:<Up>')
vim.keymap.set('c', '<A-b>', '<C-Left>')
vim.keymap.set('c', '<A-f>', '<C-Right>')
vim.keymap.set('c', '<A-d>', '<C-Right><C-w>')
vim.keymap.set('c', '<C-h>', '<BS>')
vim.keymap.set('c', '<C-d>', '<Del>')
vim.keymap.set('c', '<C-f>', '<Right>')
vim.keymap.set('c', '<C-b>', '<Left>')

-- scroll noice doc if possible
vim.keymap.set("n", "<c-f>", function()
    if not require("noice.lsp").scroll(4) then
        return "<c-f>"
    end
end, { silent = true, expr = true })

vim.keymap.set("n", "<c-b>", function()
    if not require("noice.lsp").scroll(-4) then
        return "<c-b>"
    end
end, { silent = true, expr = true })

vim.keymap.set({ "i", "s" }, "<c-f>", function()
    if not require("noice.lsp").scroll(4) then
        return "<Right>"
    end
end, { silent = true, expr = true })

vim.keymap.set({ "i", "s" }, "<c-b>", function()
    if not require("noice.lsp").scroll(-4) then
        return "<Left>"
    end
end, { silent = true, expr = true })

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

vim.keymap.set("n", "<M-h>", function() change_width("left") end, { desc = "Resize window left" })
vim.keymap.set("n", "<M-l>", function() change_width("right") end, { desc = "Resize window right" })
vim.keymap.set("n", "<M-k>", function() change_width("up") end, { desc = "Resize window up" })
vim.keymap.set("n", "<M-j>", function() change_width("down") end, { desc = "Resize window down" })

vim.keymap.set({ "x", "n" }, "+", "\"+", { desc = "+ for system clipboard register" })
vim.keymap.set({ "x", "n" }, "_", "\"_", { desc = "_ for void register" })
vim.keymap.set("x", "P", "pgv=", { desc = "Paste and indent in visual mode" })
vim.keymap.set("n", "gp", "`[v`]", { desc = "Select last pasted text" })

vim.keymap.set("n", "<leader>'", vim.cmd.Lazy, { desc = "Open Lazy UI" })

vim.keymap.set("n", "<leader>xl", ":.lua<CR>", { desc = "Run current line with lua" })
vim.keymap.set("x", "<leader>xl", ":lua<CR>", { desc = "Run visual selection with lua" })
