return {
  "lewis6991/gitsigns.nvim",
  cond = not vim.g.rpi,
  lazy = false,
  keys = {
    { "[h", desc = "Goto previous hunk" },
    { "]h", desc = "Goto next hunk" },
    { "gb", desc = "Toggle blame" },
    { "gh", desc = "Preview hunk" },
    { "gH", desc = "Reset hunk" },
  },
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "│" },
    },
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      vim.keymap.set("n", "[h", function()
        gitsigns.nav_hunk("prev")
        gitsigns.preview_hunk()
      end, { buffer = bufnr })

      vim.keymap.set("n", "]h", function()
        gitsigns.nav_hunk("next")
        gitsigns.preview_hunk()
      end, { buffer = bufnr })

      vim.keymap.set("n", "gb", gitsigns.toggle_current_line_blame, { buffer = bufnr })
      vim.keymap.set("n", "gh", gitsigns.preview_hunk, { buffer = bufnr })
      vim.keymap.set("n", "gH", gitsigns.preview_hunk_inline, { buffer = bufnr })
      vim.keymap.set("n", "gX", gitsigns.reset_hunk, { buffer = bufnr })
    end,
  },
}
