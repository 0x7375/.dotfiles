return {
    'Wansmer/treesj',
    cond = vim.g.rpi,
    keys = {
        { '<leader>nj', function() require('treesj').join() end,  desc = "Join node" },
        { '<leader>ns', function() require('treesj').split() end, desc = "Split node" },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
        use_default_keymaps = false,
    },
}
