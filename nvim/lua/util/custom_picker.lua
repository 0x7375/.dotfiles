local M = {}

local ok, action_state = pcall(require, "telescope.actions.state")
if not ok then
  return
end

---@param prompt_bufnr number: The prompt bufnr
function M.toggle_fullscreen(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)

  picker.fullscreen = not picker.fullscreen
  picker:full_layout_update()
end

ok, Layout = pcall(require, "telescope.pickers.layout")
if not ok then
  return
end

local function create_window(is_focused, width, height, row, col, border)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local winid = vim.api.nvim_open_win(bufnr, is_focused, {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = border,
    title = "",
  })

  vim.wo[winid].winhighlight = "Normal:Normal"

  return Layout.Window({
    bufnr = bufnr,
    winid = winid,
  })
end

local function update_window(window, width, height, row, col, border)
  vim.api.nvim_win_set_config(window.winid, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = border,
  })
end

local function destroy_window(window)
  if window then
    if vim.api.nvim_win_is_valid(window.winid) then
      vim.api.nvim_win_close(window.winid, true)
    end
    if vim.api.nvim_buf_is_valid(window.bufnr) then
      vim.api.nvim_buf_delete(window.bufnr, { force = true })
    end
  end
end

local top_border = 1
local bottom_border = 1

local prompt_height = 1
local prompt_height_with_border = prompt_height + top_border

local function calculate_dimensions(picker)
  local window_width
  local window_height
  local lines = vim.o.lines - vim.o.cmdheight
  local columns = vim.o.columns
  if picker.fullscreen then
    window_width = columns
    window_height = lines
  else
    window_width = math.floor(columns * 0.6)
    window_height = math.floor(lines * 0.7)
  end

  local x_centered = math.floor((columns - window_width) / 2)

  local y_offset = -2
  if window_height + math.abs(y_offset) > lines then
    y_offset = lines - window_height
  end

  local y_centered = math.floor((lines - window_height) / 2) + y_offset

  local preview_height = 0
  local preview_height_with_border = 0

  if picker.previewer then
    preview_height = math.floor(window_height * 0.6)
    preview_height_with_border = preview_height + top_border + bottom_border
  end

  local results_height = window_height - preview_height_with_border - prompt_height_with_border - bottom_border

  return window_width, window_height, x_centered, y_centered, preview_height, preview_height_with_border, results_height
end

local PREVIEW_BORDER = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }
local PROMPT_BORDER = { "┌", "─", "┐", "│", "", "", "", "│" }
local RESULTS_BORDER = { "", "", "", "│", "┘", "─", "└", "│" }

function M.create_layout(picker)
  local window_width, window_height, x_centered, y_centered, preview_height, preview_height_with_border, results_height =
    calculate_dimensions(picker)

  local layout = Layout({
    picker = picker,
    mount = function(self)
      if picker.previewer then
        self.preview = create_window(false, window_width, preview_height, y_centered, x_centered, PREVIEW_BORDER)
      end
      self.prompt = create_window(
        true,
        window_width,
        prompt_height,
        y_centered + preview_height_with_border,
        x_centered,
        PROMPT_BORDER
      )
      self.results = create_window(
        false,
        window_width,
        results_height,
        y_centered + preview_height_with_border + prompt_height_with_border,
        x_centered,
        RESULTS_BORDER
      )
    end,
    unmount = function(self)
      destroy_window(self.preview)
      destroy_window(self.prompt)
      destroy_window(self.results)
    end,
    update = function(self)
      window_width, window_height, x_centered, y_centered, preview_height, preview_height_with_border, results_height =
        calculate_dimensions(picker)

      if picker.previewer then
        if not self.preview then
          self.preview = create_window(false, window_width, preview_height, y_centered, x_centered, PREVIEW_BORDER)
        else
          update_window(self.preview, window_width, preview_height, y_centered, x_centered, PREVIEW_BORDER)
        end
      else
        if self.preview then
          destroy_window(self.preview)
          self.preview = nil
        end
      end

      update_window(
        self.prompt,
        window_width,
        prompt_height,
        y_centered + preview_height_with_border,
        x_centered,
        PROMPT_BORDER
      )

      update_window(
        self.results,
        window_width,
        results_height,
        y_centered + preview_height_with_border + prompt_height_with_border,
        x_centered,
        RESULTS_BORDER
      )
    end,
  })

  return layout
end

return M
