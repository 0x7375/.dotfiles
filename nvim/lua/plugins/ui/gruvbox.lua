return {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    init = function()
        vim.api.nvim_set_hl(0, "Comment", { link = "NonText" })
    end,
    config = function()
        require("gruvbox").setup({
            transparent_mode = false,
            dim_inactive = false,
            overrides = {
                RainbowPurple = { link = "GruvboxPurple" },
                RainbowBlue = { link = "GruvboxBlue" },
                RainbowGreen = { link = "GruvboxAqua" },
                RainbowCyan = { link = "GruvboxGreen" },
                RainbowYellow = { link = "GruvboxYellow" },
                RainbowOrange = { link = "GruvboxOrange" },

                -- consistent borders
                Pmenu = { link = "Normal" },
                FloatBorder = { link = "NonText" },
                FzfLuaBorder = { link = "NonText" },
                LspInfoBorder = { link = "NonText" },
                TelescopeBorder = { link = "NonText" },
                TelescopePromptBorder = { link = "NonText" },
                TelescopePreviewBorder = { link = "NonText" },
                TelescopeResultsBorder = { link = "NonText" },

                TelescopeSelectionCaret = { link = "GruvboxAqua" },
                TelescopePromptPrefix = { link = "GruvboxYellow" },
                TelescopePromptCounter = { link = "GruvboxYellow" },
                TelescopeNormal = { link = "Normal" },
                TelescopeSelection = { link = "GruvboxAquaSign" },

                -- cleaner window separator
                WinSeparator = { link = "NonText" },

                StatusLine = { link = "WinSeparator" },
                StatusLineNC = { link = "WinSeparator" },
                WinBar = { link = "WinSeparator" },
                WinBarNC = { link = "WinSeparator" },
            },
            bold = true,
            italic = {
                strings = false,
                emphasis = false,
                comments = false,
                operators = false,
                folds = false,
            },
        })
        vim.cmd.colorscheme("gruvbox")
    end
}
