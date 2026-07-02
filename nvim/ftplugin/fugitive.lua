local bufnr = vim.api.nvim_get_current_buf()

map("n", "p", function() vim.cmd.Git("push") end, { desc = "Fugitive: git push", buffer = bufnr })
map("n", "P", function() vim.cmd.Git("pull --rebase") end, { desc = "Fugitive: git pull", buffer = bufnr })
map("n", "q", vim.cmd.tabclose, { desc = "Close fugitive ", buffer = bufnr })
map("n", "s", "V", { desc = "Visual line selection", buffer = bufnr })
map({ "n", "x" }, "l", "-", { desc = "Fugitive: stage/unstage", remap = true, buffer = bufnr })
map({ "n", "x" }, "h", "=", { desc = "Fugitive: show/hide diff", remap = true, buffer = bufnr })
map(
  { "n", "x" },
  "cK",
  function() vim.cmd.Git("resign") end,
  { desc = "Fugitive: try to sign the last commit again", remap = true, buffer = bufnr }
)
