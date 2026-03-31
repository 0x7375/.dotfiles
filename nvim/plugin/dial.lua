pack({ "monaqa/dial.nvim" })

local augend = require("dial.augend")

local opts = {
  default = {
    augend.constant.alias.bool,
    augend.integer.alias.decimal_int,
    augend.date.alias["%d/%m/%Y"],

    augend.constant.new({
      elements = { "True", "False" },
      word = true, -- if false, testTrue gets transformed into testFalse otherwise nothing
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "TRUE", "FALSE" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "left", "right" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "LEFT", "RIGHT" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "Left", "Right" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "and", "or" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "on", "off" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "&&", "||" },
      word = false, -- word|| is allowed to become word&&
      cyclic = true,
    }),
  },
}

require("dial.config").augends:register_group(opts)

local dial_map = require("dial.map")
map("n", "<C-a>", dial_map.inc_normal(), { desc = "Increment", noremap = true })
map("n", "g<C-a>", dial_map.inc_gnormal(), { desc = "Increment", noremap = true })
map("x", "<C-a>", dial_map.inc_visual(), { desc = "Increment", noremap = true })
map("x", "g<C-a>", dial_map.inc_gvisual(), { desc = "Increment", noremap = true })

map("n", "<C-x>", dial_map.dec_normal(), { desc = "Decrement", noremap = true })
map("n", "g<C-x>", dial_map.dec_gnormal(), { desc = "Decrement", noremap = true })
map("x", "<C-x>", dial_map.dec_visual(), { desc = "Decrement", noremap = true })
map("x", "g<C-x>", dial_map.dec_gvisual(), { desc = "Decrement", noremap = true })
