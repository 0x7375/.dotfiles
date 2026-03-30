local ts_dir = require("nix-info")(nil, "plugins", "start", "nvim-treesitter")
local grammars_dir = require("nix-info")(nil, "plugins", "start", "COLLATED_TS_GRAMMARS")

return {
  "nvim-treesitter/nvim-treesitter",
  enabled = ts_dir ~= nil,
  dir = ts_dir,
  lazy = false,
  main = "nvim-treesitter.configs",
  dependencies = {
    {
      "nix-ts-grammars",
      dir = grammars_dir,
      enabled = grammars_dir ~= nil,
    },
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      opts = {
        select = { lookahead = true },
        move = { set_jumps = true },
      },
      config = function(_, opts)
        require("nvim-treesitter-textobjects").setup(opts)

        local map = vim.keymap.set
        local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
        local move = require("nvim-treesitter-textobjects.move")
        local swap = require("nvim-treesitter-textobjects.swap")

        local function select(q)
          return function() select_textobject(q, "textobjects") end
        end

        local function jump(fn, q)
          return function() fn(q, "textobjects") end
        end

        map({ "x", "o" }, "aa", select("@parameter.outer"))
        map({ "x", "o" }, "ia", select("@parameter.inner"))
        map({ "x", "o" }, "af", select("@function.outer"))
        map({ "x", "o" }, "if", select("@function.inner"))
        map({ "x", "o" }, "ac", select("@class.outer"))
        map({ "x", "o" }, "ic", select("@class.inner"))

        map({ "n", "x", "o" }, "]m", jump(move.goto_next_start, "@function.outer"))
        map({ "n", "x", "o" }, "]M", jump(move.goto_next_end, "@function.outer"))
        map({ "n", "x", "o" }, "[m", jump(move.goto_previous_start, "@function.outer"))
        map({ "n", "x", "o" }, "[M", jump(move.goto_previous_end, "@function.outer"))

        map({ "n", "x", "o" }, "]c", jump(move.goto_next_start, "@class.outer"))
        map({ "n", "x", "o" }, "]C", jump(move.goto_next_end, "@class.outer"))
        map({ "n", "x", "o" }, "[c", jump(move.goto_previous_start, "@class.outer"))
        map({ "n", "x", "o" }, "[C", jump(move.goto_previous_end, "@class.outer"))

        map("n", "<leader>i", function() swap.swap_next("@parameter.inner") end)
        map("n", "<leader>I", function() swap.swap_previous("@parameter.inner") end)
      end,
    },
    {
      "Wansmer/treesj",
      cond = not vim.g.rpi,
      keys = {
        { "<leader>nj", function() require("treesj").join() end, desc = "Join node" },
        { "<leader>ns", function() require("treesj").split() end, desc = "Split node" },
      },
      opts = {
        use_default_keymaps = false,
      },
    },
    {
      "HiPhish/rainbow-delimiters.nvim",
      config = function()
        require("rainbow-delimiters.setup").setup({
          blacklist = {
            "html",
          },
          highlight = {
            "RainbowOrange",
            "RainbowYellow",
            "RainbowCyan",
            "RainbowViolet",
            "RainbowGreen",
            "RainbowBlue",
          },
        })
      end,
    },
  },
  opts = {
    indent = { enable = true },
    highlight = {
      enable = true,
      disable = function(lang, buf)
        if vim.tbl_contains({ "csv" }, lang) then
          return true
        end

        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },
  },
}
