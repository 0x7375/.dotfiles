return {
  {
    "VebbNix/lf-vim",
    ft = "lf",
  },
  {
    "MTDL9/vim-log-highlighting",
    ft = "log",
  },
  {
    "cameron-wags/rainbow_csv.nvim",
    init = function() vim.g.disable_rainbow_statusline = 1 end,
    config = true,
    ft = {
      "csv",
      "tsv",
      "csv_semicolon",
      "csv_whitespace",
      "csv_pipe",
      "rfc_csv",
      "rfc_semicolon",
    },
    cmd = {
      "RainbowDelim",
      "RainbowDelimSimple",
      "RainbowDelimQuoted",
      "RainbowMultiDelim",
    },
  },
}
