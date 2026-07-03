local M = {}

M.build_bar = function()
  local branch = vim.fn.FugitiveStatusline():match("%[Git%((.-)%)%]") or ""
  branch = branch ~= "" and branch .. " " or ""

  local set_green = "%#Directory#"
  local set_normal = "%#Dim#"
  local file_name = " " .. vim.fn.expand("%:~:.")

  local modified = ""
  if vim.bo.readonly then
    modified = " "
  elseif vim.bo.modified then
    modified = " ●"
  end

  local align_right = "%="
  local position = "%l,%c"

  local search_count = ""
  local mode = vim.api.nvim_get_mode().mode

  if mode ~= "i" and vim.v.hlsearch == 1 and vim.fn.getreg("/") ~= "" then
    local s_count = vim.fn.searchcount({ recompute = 1, maxcount = 999 })
    if s_count and s_count.total and s_count.total > 0 then
      search_count = string.format("[%d/%d]", s_count.current, s_count.total) .. " "
    end
  end

  local recording = ""
  local reg = vim.fn.reg_recording()
  if reg ~= "" then
    recording = " @" .. reg
  end

  local pending = "%S "

  return table.concat({
    set_normal,
    file_name,
    modified,
    recording,
    align_right,
    pending,
    set_green,
    branch,
    set_normal,
    search_count,
    position,
  }, "")
end

local filetype_exclude = {
  -- "fugitive",
  "nvim-pack",
  "dap-view",
  "dap-repl",
  "oil",
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
