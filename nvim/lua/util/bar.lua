local M = {}

local git_cache = ""

local function setup_git_watch()
  local git_dir = vim.fn.finddir(".git", ".;")

  if not git_dir then
    return
  end

  local head_file = git_dir .. "/HEAD"
  local event = vim.uv.new_fs_event()

  if not event then
    return
  end

  vim.uv.fs_event_start(event, head_file, {}, vim.schedule_wrap(function() M.refresh() end))
end

setup_git_watch()

local function git_branch()
  if git_cache ~= "" then
    return git_cache
  end

  local ref = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
  local branch = ""
  if ref == "HEAD" then
    branch = vim.fn.system("git rev-parse --short HEAD 2>/dev/null | tr -d '\n'")
  elseif ref ~= "" then
    branch = ref
  end

  git_cache = branch
  return branch
end

vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    git_cache = ""
    setup_git_watch()
    M.refresh()
  end,
})

M.build_bar = function()
  local branch = git_branch()
  branch = " " .. branch

  local set_green = "%#GruvboxGreen#"
  local set_normal = "%#Dim#"
  local file_name = " " .. vim.fn.expand("%:~:.")

  local modified = ""
  if vim.bo.readonly then
    modified = " "
  elseif vim.bo.modified then
    modified = " ●"
  end

  local align_right = "%="
  local position = " %l,%c"

  local search_count = ""
  local mode = vim.api.nvim_get_mode().mode

  if mode ~= "i" and vim.v.hlsearch == 1 and vim.fn.getreg("/") ~= "" then
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
  "nvim-pack",
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
  if not validate_buffer() then
    return
  end
  vim.wo.winbar = M.build_bar()
end

M.init = function()
  if not validate_buffer() then
    return
  end
  vim.opt.winbar = M.build_bar()
end

return M
