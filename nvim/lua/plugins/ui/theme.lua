return {
    "amedoeyes/eyes.nvim",
    lazy = false,
    priority = 1000,
    init = function()
        -- read theme on startup
        local f = io.open(vim.fn.expand("~/.local/state/current_theme"), "r")
        if f then
            local theme = f:read("*all"):gsub("%s+", "")
            f:close()
            vim.o.background = theme
        end

        vim.cmd.colorscheme("eyes")
        vim.api.nvim_set_hl(0, "PmenuSel", { reverse = true })

        vim.api.nvim_create_autocmd("OptionSet", {
            pattern = "background",
            callback = function()
                vim.api.nvim_set_hl(0, "PmenuSel", { reverse = true })
            end,
        })
    end,
}
