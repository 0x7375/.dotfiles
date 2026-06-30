-- handle camel case etc
vim.g.wordmotion_spaces = { "-", "_" }

-- replace with register
-- remove default conflicting lsp mappings
del({ "n", "x" }, "gra")
del("n", "gri")
del("n", "grn")
del("n", "grr")
del("n", "grt")

-- automatically create html tags
require("nvim-ts-autotag").setup({ autotag = true })

-- surround with motions
require("nvim-surround")

-- move stuff
require("mini.move").setup({
  mappings = {
    left = "H",
    right = "L",
    down = "J",
    up = "K",

    line_left = "",
    line_right = "",
    line_down = "",
    line_up = "",
  },

  options = {
    reindent_linewise = true,
  },
})
