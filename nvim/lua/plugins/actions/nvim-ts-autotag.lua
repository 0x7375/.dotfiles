return {
    'windwp/nvim-ts-autotag',
    ft = { "html", "php" },
    cond = vim.g.rpi,
    opts = {
        autotag = true,
    }
}
