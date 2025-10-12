return {
    {
        "kdheepak/monochrome.nvim",
        enabled = false,
        init = function()
            vim.cmd.colorscheme("monochrome")
            vim.api.nvim_set_hl(0, "Pmenu", { link = "Normal" })

            vim.api.nvim_set_hl(0, "FloatBorder", { link = "Comment" })
            vim.api.nvim_set_hl(0, "FzfLuaBorder", { link = "Comment" })
            vim.api.nvim_set_hl(0, "LspInfoBorder", { link = "Comment" })
            vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "Comment" })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "Comment" })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "Comment" })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "Comment" })

            vim.api.nvim_set_hl(0, "WinSeparator", { link = "Comment" })
            vim.api.nvim_set_hl(0, "StatusLine", { link = "WinSeparator" })
            vim.api.nvim_set_hl(0, "StatusLineNC", { link = "WinSeparator" })
            vim.api.nvim_set_hl(0, "Winbar", { link = "WinSeparator" })
            vim.api.nvim_set_hl(0, "WinbarNC", { link = "WinSeparator" })
        end,
    },
    {
        "amedoeyes/eyes.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        init = function()
            vim.cmd.colorscheme("eyes")
        end,
    },
}
