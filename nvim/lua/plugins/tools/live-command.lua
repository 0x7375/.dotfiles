return {
    'smjonas/live-command.nvim',
    cmd = { "Norm" },
    init = function()
        vim.cmd("cnoreabbrev norm Norm")
    end,
    opts = {
        inline_highlighting = false,
        commands = {
            Norm = { cmd = "norm" },
        }
    },
    config = function(_, opts)
        require("live-command").setup(opts)
    end,
}
