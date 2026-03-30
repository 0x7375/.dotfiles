return {
  "tpope/vim-fugitive",
  keys = {
    { "<leader>g", function() vim.cmd("tab Git") end, desc = "Open fugitive" },
    { "p", function() vim.cmd.Git("push") end, ft = "fugitive", desc = "Fugitive: git push" },
    { "P", function() vim.cmd.Git("pull --rebase") end, ft = "fugitive", desc = "Fugitive: git pull" },
    { "q", vim.cmd.tabclose, ft = "fugitive", desc = "Close fugitive " },
    { "s", "V", ft = "fugitive", desc = "Visual line selection" },
    { "S", "s", ft = "fugitive", desc = "Fugitive: stage" },
  },
}
