return {
    'lukas-reineke/indent-blankline.nvim',
    cond = false,
    main = "ibl",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    ---@module "ibl"
    ---@type ibl.config
    opts = {
        indent = {
            -- char = "⎜"
            char = "▏", -- thinner one
        },
        scope = {
            enabled = true,
            show_start = false,
            show_end = false,
            highlight = {
                "RainbowOrange",
                "RainbowYellow",
                "RainbowCyan",
                "RainbowPurple",
                "RainbowGreen",
                "RainbowBlue",
            }
        },
    },
    config = function(_, opts)
        require("ibl").setup(opts)
        local hooks = require "ibl.hooks"
        hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
}
