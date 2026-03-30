return {
  "ThePrimeagen/harpoon",
  dependencies = "nvim-lua/plenary.nvim",
  branch = "harpoon2",
  keys = {
    {
      "<leader>a",
      function()
        require("harpoon"):list():add()
        print(vim.fn.fnamemodify(vim.fn.expand("%"), ":t") .. " added to harpoon")
      end,
      desc = "Add file to harpoon",
    },
    {
      "<C-e>",
      function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,
      desc = "Toggle harpoon ui",
    },
    {
      "<C-h>",
      function()
        require("harpoon"):list():select(1)
        vim.cmd([[normal zz]])
      end,
      desc = "Harpoon: select file 1",
    },
    {
      "<C-j>",
      function()
        require("harpoon"):list():select(2)
        vim.cmd([[normal zz]])
      end,
      desc = "Harpoon: select file 2",
    },
    {
      "<C-k>",
      function()
        require("harpoon"):list():select(3)
        vim.cmd([[normal zz]])
      end,
      desc = "Harpoon: select file 3",
    },
    {
      "<C-l>",
      function()
        require("harpoon"):list():select(4)
        vim.cmd([[normal zz]])
      end,
      desc = "Harpoon: select file 4",
    },
  },
  opts = {
    settings = {
      save_on_toggle = true,
    },
  },
}
