return {
  "windwp/nvim-ts-autotag",
  ft = { "html", "php" },
  cond = not vim.g.rpi,
  opts = {
    autotag = true,
  },
}
