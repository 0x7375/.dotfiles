return {
    'smjonas/live-command.nvim',
    cmd = { "Norm", "G", "S" },
    opts = {
        commands = {
            Norm = { cmd = "norm" },
            G = { cmd = "g" },
            S = { cmd = "s" },
        }
    },
    config = function(_, opts)
        require("live-command").setup(opts)
    end,
}
