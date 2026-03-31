-- handle camel case etc
pack({ "chaoren/vim-wordmotion" })
vim.g.wordmotion_spaces = { "-", "_" }

-- indentation motions
pack({ "michaeljsmith/vim-indent-object" })

-- replace with register
pack({ "vim-scripts/ReplaceWithRegister" })
-- remove default conflicting lsp mappings
del({ "n", "x" }, "gra")
del("n", "gri")
del("n", "grn")
del("n", "grr")
del("n", "grt")

-- automatically create html tags
on_filetype("html,php", function()
  pack({ "windwp/nvim-ts-autotag" })
  require("nvim-ts-autotag").setup({ autotag = true })
end)

-- surround with motions
pack({ "kylechui/nvim-surround" })
require("nvim-surround")

-- move stuff
pack({ "nvim-mini/mini.move" })
require("mini.move").setup({
  mappings = {
    left = "H",
    right = "L",
    down = "J",
    up = "K",

    line_left = "<M-h>",
    line_right = "<M-l>",
    line_down = "<M-j>",
    line_up = "<M-k>",
  },

  options = {
    reindent_linewise = false,
  },
})
