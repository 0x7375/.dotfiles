return {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    init = function()
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { link = "NonText" })
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { link = "NonText" })
        vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { link = "NonText" })
        vim.api.nvim_set_hl(0, "NoiceCmdlineBorder", { link = "NonText" })
    end,
    config = function()
        local palette = require("gruvbox").palette

        require("gruvbox").setup({
            transparent_mode = false,
            palette_overrides = {
                -- dark1 = palette.dark0_hard,
            },
            overrides = {
                PmenuSel = { fg = palette.dark0_hard, bg = palette.neutral_aqua },
                CmpItemAbbrMatch = { link = "GruvboxAqua" },

                LineNrBelow = { link = "Comment" },
                LineNrAbove = { link = "Comment" },
                LineNr = { link = "Normal" },
                CursorLineNr = { link = "Normal" },

                SignColumn = { bg = palette.dark0_hard },
                ColorColumn = { bg = "#131516" },
                GruvboxYellowSign = { bg = palette.dark0_hard },
                GruvboxRedSign = { bg = palette.dark0_hard },
                GruvboxAquaSign = { bg = palette.dark0_hard },
                GruvboxBlueSign = { bg = palette.dark0_hard },
                GruvboxGreenSign = { bg = palette.dark0_hard },
                GruvboxOrangeSign = { bg = palette.dark0_hard },
                GruvboxPurpleSign = { bg = palette.dark0_hard },

                CursorLine = { bg = palette.dark0 },
                Comment = { link = "NonText" },
                Visual = { bg = palette.dark1 },
                YankyYanked = { link = "IncSearch" },

                RainbowPurple = { link = "GruvboxPurple" },
                RainbowBlue = { link = "GruvboxBlue" },
                RainbowGreen = { link = "GruvboxAqua" },
                RainbowCyan = { link = "GruvboxGreen" },
                RainbowYellow = { link = "GruvboxYellow" },
                RainbowOrange = { link = "GruvboxOrange" },

                NormalFloat = { bg = palette.dark0_hard },

                -- consistent borders
                Pmenu = { link = "Normal" },
                FloatBorder = { link = "NonText" },
                FzfLuaBorder = { link = "NonText" },
                LspInfoBorder = { link = "NonText" },
                TelescopeBorder = { link = "NonText" },
                TelescopePromptBorder = { link = "NonText" },
                TelescopePreviewBorder = { link = "NonText" },
                TelescopeResultsBorder = { link = "NonText" },

                TelescopeSelectionCaret = { fg = palette.neutral_aqua, bg = palette.dark1, bold = true },
                TelescopePromptPrefix = { fg = palette.bright_yellow, bold = true },
                TelescopePromptCounter = { fg = palette.bright_yellow },
                TelescopeNormal = { fg = palette.light2 },
                TelescopeSelection = { fg = palette.light1, bg = palette.dark1, bold = true },

                CmpGhostText = { link = "Comment" },

                -- cleaner window separator
                WinSeparator = { link = "NonText" },
                StatusLine = { link = "WinSeparator" },
                StatusLineNC = { link = "WinSeparator" },

                ["@variable.php"] = { fg = palette.bright_blue },
            },
            contrast = "hard",
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
