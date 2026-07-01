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

-- multicursor
local mc = require("multicursor-nvim")
mc.setup()

map({ "n", "x" }, "<leader>m", function() mc.matchAddCursor(1) end)

mc.addKeymapLayer(function(layerMap)
  layerMap({ "n", "x" }, "[", mc.prevCursor)
  layerMap({ "n", "x" }, "]", mc.nextCursor)

  layerMap({ "n", "x" }, "Q", function() mc.matchSkipCursor(-1) end)
  layerMap({ "n", "x" }, "q", function() mc.matchSkipCursor(1) end)

  layerMap({ "n", "x" }, "N", function() mc.matchAddCursor(-1) end)
  layerMap({ "n", "x" }, "n", function() mc.matchAddCursor(1) end)

  layerMap("n", "<ESC>", mc.clearCursors)
end)
