-- Remove new line comments behaviour on every file
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*",
    command = "setlocal formatoptions-=cro"
})

-- comment vimv lines
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        if vim.env.VIMV then
            vim.api.nvim_buf_set_option(0, 'commentstring', '# %s')
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

-- Clear the command line on cursor move
vim.api.nvim_create_autocmd("CursorMoved", {
    callback = function()
        vim.cmd("echon ''")
    end,
})

-- Redirect command output to temp buffer -> :Redir lua=require("telescope")
vim.api.nvim_create_user_command('Redir', function(ctx)
    local result = vim.api.nvim_exec2(ctx.args, { output = true })
    local lines = vim.split(result.output or '', '\n', { plain = true })
    vim.cmd('new')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.opt_local.modified = false
end, { nargs = '+', complete = 'command' })

-- update winbar when needed
vim.api.nvim_create_autocmd({
        "BufEnter",
        "BufWritePost",
        -- "TextChangedI",
        "TextChanged",
        "WinEnter",
        "InsertLeave",
        "TermEnter",
        "VimEnter",
    },
    {
        callback = function()
            local winbar_filetype_exclude = {
                -- "copilot-chat",
                -- "toggleterm",
                -- "fzf",
            }

            -- no winbar for floating windows
            local win_config = vim.api.nvim_win_get_config(0)
            if win_config.relative ~= "" then
                vim.wo.winbar = ""
                return
            end

            -- if vim.tbl_contains(winbar_filetype_exclude, vim.bo.filetype) then
            --     vim.wo.winbar = ""
            --     return
            -- end

            vim.wo.winbar = require("util.bar").build_bar()
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

-- Toggle background between light and dark on SIGUSR1
vim.api.nvim_create_autocmd("Signal", {
    pattern = "SIGUSR1",
    group = vim.api.nvim_create_augroup("toggle_bg_on_SIGUSR1", {}),
    callback = function()
        local option = "background"
        local dark = vim.api.nvim_get_option_value(option, {}) == "dark"
        vim.api.nvim_set_option_value(option, dark and "light" or "dark", {})
        vim.schedule(function()
            vim.cmd("redraw!")
        end)
    end,
    nested = true,
})
