if vim.g.vscode then
  return
end

-- diff view
pack({ "esmuellert/codediff.nvim" })
require("codediff").setup({})

-- git ui
pack({ "tpope/vim-fugitive" })
map("n", "<leader>g", function() vim.cmd("tab Git") end, { desc = "Open fugitive" })

-- workspace search/replace
pack({ "MagicDuck/grug-far.nvim" })
map("n", "<leader>R", vim.cmd.GrugFar, { desc = "Search and replace project" })

-- live preview norm
pack({ "smjonas/live-command.nvim" })
require("live-command").setup({
  inline_highlighting = false,
  commands = {
    Norm = { cmd = "norm" },
  },
})
vim.cmd("cnoreabbrev norm Norm")

-- better undotree
pack({ "jiaoshijie/undotree" })
map("n", "<leader>u", function() require("undotree").toggle() end)
