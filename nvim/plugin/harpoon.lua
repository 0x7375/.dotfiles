if vim.g.vscode then
  return
end

pack({
  "nvim-lua/plenary.nvim",
  { src = "ThePrimeagen/harpoon", version = "harpoon2" },
})

require("harpoon").setup({
  settings = {
    save_on_toggle = true,
  },
})

map("n", "<leader>a", function()
  require("harpoon"):list():add()
  print(vim.fn.fnamemodify(vim.fn.expand("%"), ":t") .. " added to harpoon")
end, { desc = "Add file to harpoon" })

map(
  "n",
  "<C-e>",
  function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,
  { desc = "Toggle harpoon ui" }
)

map("n", "<C-h>", function()
  require("harpoon"):list():select(1)
  vim.cmd([[normal zz]])
end, { desc = "Harpoon: select file 1" })

map("n", "<C-j>", function()
  require("harpoon"):list():select(2)
  vim.cmd([[normal zz]])
end, { desc = "Harpoon: select file 2" })

map("n", "<C-k>", function()
  require("harpoon"):list():select(3)
  vim.cmd([[normal zz]])
end, { desc = "Harpoon: select file 3" })

map("n", "<C-l>", function()
  require("harpoon"):list():select(4)
  vim.cmd([[normal zz]])
end, { desc = "Harpoon: select file 4" })
