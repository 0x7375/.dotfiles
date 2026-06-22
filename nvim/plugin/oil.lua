pack({ "stevearc/oil.nvim" })

-- Declare a global function to retrieve the current directory
function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  else
    -- If there is no current directory (e.g. over ssh), just show the buffer name
    return vim.api.nvim_buf_get_name(0)
  end
end

require("oil").setup({
  default_file_explorer = false,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
  },
  win_options = {
    winbar = "%!v:lua.get_oil_winbar()",
  },
  columns = {
    "permissions",
    "size",
    "mtime",
  },
  preview_win = {
    max_width = vim.o.columns,
    max_height = vim.o.lines - 1 - vim.o.cmdheight,
    border = "single",
  },
  lsp_file_methods = { autosave = "modified" },
  watch_for_changes = true,
  keymaps = {
    ["H"] = "actions.parent",
    ["L"] = "actions.select",
    ["q"] = "actions.close",
    ["."] = "actions.toggle_hidden",
    ["<C-r>"] = "actions.refresh",
    ["gs"] = "actions.change_sort",
  },
})

map("n", "<leader>k", function() require("oil").open(".") end, { desc = "Toggle oil (cwd)" })
map("n", "<leader>K", function() require("oil").open(vim.fn.expand("%:p:h")) end, { desc = "Toggle oil (file dir)" })
