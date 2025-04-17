return {
    'smjonas/live-command.nvim',
    cmd = { "Norm" },
    opts = {
        commands = {
            Norm = { cmd = "norm" },
        }
    },
    config = function(_, opts)
        require("live-command").setup(opts)
    end,
}
