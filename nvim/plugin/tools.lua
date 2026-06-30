if vim.g.vscode then
  return
end

-- diff view
require("codediff").setup({})

-- git ui
map("n", "<leader>g", function() vim.cmd("tab Git") end, { desc = "Open fugitive" })

-- workspace search/replace
map("n", "<leader>R", vim.cmd.GrugFar, { desc = "Search and replace project" })

-- live preview norm
require("live-command").setup({
  inline_highlighting = false,
  commands = {
    Norm = { cmd = "norm" },
  },
})
vim.cmd("cnoreabbrev norm Norm")

-- better undotree
map("n", "<leader>u", function() require("undotree").toggle() end)
