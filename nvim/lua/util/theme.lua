local M = {}

M.update = function()
  local path = os.getenv("TINTED_FILE")
  if not path then
    return
  end

  local f = io.open(vim.fn.expand(path), "r")
  if not f then
    return
  end

  local theme = f:read("*all"):gsub("%s+", "")
  f:close()
  vim.o.background = theme
end

return M
