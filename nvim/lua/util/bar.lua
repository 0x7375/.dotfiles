local M = {}

local function git_branch()
    if vim.g.windows then return "" end
    local ref = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
    local branch = ""
    if ref == "HEAD" then
        branch = vim.fn.system("git rev-parse --short HEAD 2>/dev/null | tr -d '\n'")
    elseif ref ~= "" then
        branch = ref
    end

    return branch
end

M.build_bar = function()
    local branch = git_branch()
    branch = ' ' .. branch

    local set_green = "%#DiffAdd#"
    local set_normal = "%#Comment#"
    local file_name = " " .. vim.fn.expand("%:~:.")

    local modified = ''
    if vim.bo.readonly then
        modified = " "
    elseif vim.bo.modified then
        modified = " ●"
    end

    local align_right = "%="
    local position = " %l,%c"

    local search_count = ""
    if vim.v.hlsearch == 1 and vim.fn.getreg('/') ~= '' then
        local s_count = vim.fn.searchcount({ recompute = 1, maxcount = 999 })
        if s_count and s_count.total and s_count.total > 0 then
            search_count = string.format(" [%d/%d]", s_count.current, s_count.total)
        end
    end

    local recording = ""
    local reg = vim.fn.reg_recording()
    if reg ~= "" then
        recording = " @" .. reg
    end

    return table.concat({
        set_normal,
        file_name,
        modified,
        recording,
        align_right,
        set_green,
        branch,
        set_normal,
        search_count,
        position,
    }, "")
end

local filetype_exclude = {
    "fugitive",
    "dap-view",
    "dap-repl",
}

local function validate_buffer()
    -- no winbar for floating windows or excluded filetypes
    local win_config = vim.api.nvim_win_get_config(0)
    if vim.tbl_contains(filetype_exclude, vim.bo.filetype) or win_config.relative ~= "" then
        return false
    end
    return true
end

M.refresh = function()
    if not validate_buffer() then return end
    vim.wo.winbar = M.build_bar()
end

M.init = function()
    if not validate_buffer() then return end
    vim.opt.winbar = M.build_bar()
end

return M
