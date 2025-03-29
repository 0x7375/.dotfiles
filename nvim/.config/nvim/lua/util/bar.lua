local M = {}

local function git_branch()
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

    local set_green = "%#GruvboxGreen#"
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

    return table.concat({
        set_normal,
        file_name,
        modified,
        align_right,
        set_green,
        branch,
        set_normal,
        position,
    }, "")
end

return M
