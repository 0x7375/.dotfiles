if not vim.g.windows then
  return
end

pack({ "stevearc/oil.nvim" })

require("oil").setup({
  default_file_explorer = false,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
  },
  float = {
    padding = 0,
    max_width = vim.o.columns,
    max_height = vim.o.lines - 1 - vim.o.cmdheight,
    border = "single",
  },
  keymaps = {
    ["h"] = "actions.parent",
    ["l"] = "actions.select",
    ["<ESC>"] = "actions.close",
    ["q"] = "actions.close",
    ["."] = "actions.toggle_hidden",
    ["<C-r>"] = "actions.refresh",
    ["gs"] = "actions.change_sort",
  },
})

map("n", "<leader>k", "<cmd>Oil --float .<CR>",           { desc = "Toggle oil (cwd)" })
map("n", "<leader>K", function()
  require("oil").open_float(vim.fn.expand("%:p:h"))
end, { desc = "Toggle oil (file dir)" })
