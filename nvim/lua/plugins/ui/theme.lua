return {
    {
        "amedoeyes/eyes.nvim",
        cond = false,
        lazy = false,
        priority = 1000,
        init = function()
            require("util.theme").update()

            vim.cmd.colorscheme("eyes")
            vim.api.nvim_set_hl(0, "PmenuSel", { reverse = true })
            vim.api.nvim_set_hl(0, "StatusLine", { link = "StatusLineNC" })

            vim.api.nvim_create_autocmd("OptionSet", {
                pattern = "background",
                callback = function()
                    vim.api.nvim_set_hl(0, "PmenuSel", { reverse = true })
                end,
            })
        end,
    },
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("util.theme").update()

            require("gruvbox").setup({
                transparent_mode = false,
                dim_inactive = false,
                overrides = {
                    CmpItemAbbrMatch = { link = "GruvboxAqua" },
                    LineNrBelow = { link = "Comment" },
                    LineNrAbove = { link = "Comment" },
                    LineNr = { link = "Normal" },
                    CursorLineNr = { link = "Normal" },

                    -- CursorLine = { bg = "NONE" },

                    SignColumn = { link = "Normal" },
                    ColorColumn = { link = "CursorLine" },
                    GruvboxYellowSign = { link = "GruvboxYellow" },
                    GruvboxRedSign = { link = "GruvboxRed" },
                    GruvboxAquaSign = { link = "GruvboxAqua" },
                    GruvboxBlueSign = { link = "GruvboxBlue" },
                    GruvboxGreenSign = { link = "GruvboxGreen" },
                    GruvboxOrangeSign = { link = "GruvboxOrange" },
                    GruvboxPurpleSign = { link = "GruvboxPurple" },

                    Comment = { link = "NonText" },
                    Visual = { link = "MiniFilesCursorLine" },
                    -- Visual = { link = "CursorLine" },
                    YankyYanked = { link = "IncSearch" },

                    RainbowPurple = { link = "GruvboxPurple" },
                    RainbowBlue = { link = "GruvboxBlue" },
                    RainbowGreen = { link = "GruvboxAqua" },
                    RainbowCyan = { link = "GruvboxGreen" },
                    RainbowYellow = { link = "GruvboxYellow" },
                    RainbowOrange = { link = "GruvboxOrange" },

                    -- consistent borders
                    Pmenu = { link = "NonText" },
                    FloatBorder = { link = "NonText" },
                    FzfLuaBorder = { link = "NonText" },
                    LspInfoBorder = { link = "NonText" },
                    TelescopeBorder = { link = "NonText" },
                    TelescopePromptBorder = { link = "NonText" },
                    TelescopePreviewBorder = { link = "NonText" },
                    TelescopeResultsBorder = { link = "NonText" },

                    CmpGhostText = { link = "Comment" },

                    -- cleaner window separator
                    WinSeparator = { link = "NonText" },
                    StatusLine = { link = "WinSeparator" },
                    StatusLineNC = { link = "WinSeparator" },
                    WinBar = { link = "WinSeparator" },
                    WinBarNC = { link = "WinSeparator" },

                    BlinkCmpDoc = { link = "Normal" },
                    BlinkCmpDocBorder = { link = "NonText" },
                    BlinkCmpDocSeparator = { link = "NonText" },
                    BlinkCmpSignatureHelp = { link = "Normal" },
                    BlinkCmpSignatureHelpBorder = { link = "NonText" },
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

            vim.api.nvim_set_hl(0, "StatusLine", { link = "StatusLineNC" })
        end
    }
}
