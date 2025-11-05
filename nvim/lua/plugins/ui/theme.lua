return {
    "amedoeyes/eyes.nvim",
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
}
