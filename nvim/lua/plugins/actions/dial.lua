return {
  "monaqa/dial.nvim",
  keys = {
    { mode = { "x", "n" }, "<C-a>", desc = "Increment" },
    { mode = { "x", "n" }, "g<C-a>", desc = "Increment" },
    { mode = { "x", "n" }, "<C-x>", desc = "Decrement" },
    { mode = { "x", "n" }, "g<C-x>", desc = "Decrement" },
  },
  opts = function()
    local augend = require("dial.augend")

    return {
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
  end,
  config = function(_, opts)
    require("dial.config").augends:register_group(opts)

    vim.keymap.set("n", "<C-a>", require("dial.map").inc_normal(), { noremap = true })
    vim.keymap.set("n", "<C-x>", require("dial.map").dec_normal(), { noremap = true })
    vim.keymap.set("n", "g<C-a>", require("dial.map").inc_gnormal(), { noremap = true })
    vim.keymap.set("n", "g<C-x>", require("dial.map").dec_gnormal(), { noremap = true })
    vim.keymap.set("x", "<C-a>", require("dial.map").inc_visual(), { noremap = true })
    vim.keymap.set("x", "<C-x>", require("dial.map").dec_visual(), { noremap = true })
    vim.keymap.set("x", "g<C-a>", require("dial.map").inc_gvisual(), { noremap = true })
    vim.keymap.set("x", "g<C-x>", require("dial.map").dec_gvisual(), { noremap = true })
  end,
}
