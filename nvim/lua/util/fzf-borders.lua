local _single = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }
local M = {}

M.main_border = function(_, m)
  assert(m.type == "nvim" and m.name == "fzf")
  if m.nwin == 1 then
    return _single
  end

  assert(type(m.layout) == "string")
  local b = vim.deepcopy(_single)

  if m.layout == "down" then
    b[5], b[6], b[7] = "┤", "", "├"
  elseif m.layout == "up" then
    b[1], b[3] = "├", "┤"
  elseif m.layout == "left" then
    b[1], b[8], b[7] = "┬", "", "┴"
  else
    b[3], b[4], b[5] = "┬", "", "┴"
  end
  return b
end

M.preview_border = function(_, m)
  if m.type == "fzf" then
    return "border-sharp"
  end

  if m.opts.winopts.split then
    assert(m.type == "nvim" and m.name == "prev" and type(m.layout) == "string")
    local b = { "", "", "", "", "", "", "", "" }
    if m.layout == "down" then
      b[1], b[2], b[3] = "─", "─", "─"
    elseif m.layout == "up" then
      b[5], b[6], b[7] = "─", "─", "─"
    elseif m.layout == "left" then
      b[4] = "│"
    else
      b[8] = "│"
    end
    return b
  end

  assert(m.type == "nvim" and m.name == "prev" and type(m.layout) == "string")
  local b = vim.deepcopy(_single)

  if m.layout == "down" then
    b[1], b[3] = "├", "┤"
  elseif m.layout == "up" then
    b[7], b[6], b[5] = "├", "", "┤"
  elseif m.layout == "left" then
    b[3], b[5] = "┬", "┴"
  else
    b[1], b[7] = "┬", "┴"
  end
  return b
end

return M
