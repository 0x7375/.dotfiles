-- Remove new line comments behaviour on every file
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*",
    command = "setlocal formatoptions-=cro"
})

-- comment vimv lines
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        if vim.env.VIMV then
            vim.api.nvim_set_option_value('commentstring', '# %s', { buf = 0 })
        end
    end
})

vim.filetype.add({
    extension = {
        lock = 'json'
    },
})

vim.filetype.add({
    extension = {
        g4 = 'antlr4'
    },
})

vim.filetype.add({
    extension = {
        code = 'c'
    },
})

-- go to last loc when opening a buffer
local function augroup(name)
    return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
            return
        end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- User event to check if in a git repo
local function check_git_repo()
    local cmd = "git rev-parse --is-inside-work-tree"
    if vim.fn.system(cmd) == "true\n" then
        vim.api.nvim_exec_autocmds("User", { pattern = "InGitRepo" })
        return true -- removes autocmd after lazy loading git related plugins
    end
end
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    callback = function()
        vim.schedule(check_git_repo)
    end
})

-- -- Clear the command line on cursor move
-- vim.api.nvim_create_autocmd("CursorMoved", {
--     callback = function()
--         vim.cmd("echon ''")
--     end,
-- })

-- update winbar when needed
vim.api.nvim_create_autocmd({
        "BufEnter",
        "BufWritePost",
        "TextChanged",
        "TextChangedI",
        "WinEnter",
        "TermEnter",
        "VimEnter",
    },
    {
        callback = function()
            require("util.bar").refresh()
        end
    })

-- set pwd to first argument if said argument is a directory
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 1 then
            local target = vim.fn.argv(0)
            if vim.fn.isdirectory(target) == 1 then
                vim.cmd("cd " .. vim.fn.fnameescape(target))
            end
        end
    end,
})

-- reload theme on SIGUSR1
vim.api.nvim_create_autocmd("Signal", {
    pattern = "SIGUSR1",
    group = vim.api.nvim_create_augroup("reload_theme_on_SIGUSR1", {}),
    callback = function()
        local f = io.open(vim.fn.expand("~/.local/state/current_theme"), "r")
        if not f then
            return
        end

        local theme = f:read("*all"):gsub("%s+", "")
        f:close()
        vim.o.background = theme
    end,

    nested = true,
})

-- open binary files with default application
local function open()
    local prev_buf = vim.fn.bufnr('%')
    local fn = vim.fn.expand('%:p')
    vim.ui.open(fn)
    print(string.format("Opening file: %s", fn))

    if vim.fn.buflisted(prev_buf) == 1 then
        vim.api.nvim_set_current_buf(prev_buf)
    end

    vim.api.nvim_buf_delete(0, { force = true })
end

local bin_files = vim.api.nvim_create_augroup("binFiles", { clear = true })

local file_types = {
    "pdf", "jpg", "jpeg", "webp", "png", "mp3", "mp4",
    "xls", "xlsx", "xopp", "gif", "doc", "docx", "gaphor"
}

for _, ext in ipairs(file_types) do
    vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
        pattern = "*." .. ext,
        group = bin_files,
        callback = open
    })
end
