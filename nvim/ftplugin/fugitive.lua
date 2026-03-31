local bufnr = vim.api.nvim_get_current_buf()

map("n", "p", function() vim.cmd.Git("push") end, { desc = "Fugitive: git push", buffer = bufnr })
map("n", "P", function() vim.cmd.Git("pull --rebase") end, { desc = "Fugitive: git pull", buffer = bufnr })
map("n", "q", vim.cmd.tabclose, { desc = "Close fugitive ", buffer = bufnr })
map("n", "s", "V", { desc = "Visual line selection", buffer = bufnr })
map("n", "S", "s", { desc = "Fugitive: stage", buffer = bufnr })
