return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
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
  end,
}
