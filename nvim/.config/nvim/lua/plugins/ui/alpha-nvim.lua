return {
    'goolord/alpha-nvim',
    cond = false,
    init = function()
        -- Fix <C-o> behavior
        vim.keymap.set('n', '<C-o>', function()
            if vim.bo.filetype == 'alpha' then
                -- Send <C-o> twice
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-o><C-o>', true, true, true), 'n', true)
            else
                -- Send <C-o> once
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-o>', true, true, true), 'n', true)
            end
        end)
    end,
    config = function()
        if vim.fn.argc() ~= 0 then
            return
        end
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")
        -- from https://github.com/geryzhydrox/Dotfiles
        dashboard.section.header.val = {
            "          ▗▄▄▄       ▗▄▄▄▄    ▄▄▄▖          ",
            "          ▜███▙       ▜███▙  ▟███▛          ",
            "           ▜███▙       ▜███▙▟███▛           ",
            "            ▜███▙       ▜██████▛            ",
            "     ▟█████████████████▙ ▜████▛     ▟▙      ",
            "    ▟███████████████████▙ ▜███▙    ▟██▙     ",
            "           ▄▄▄▄▖           ▜███▙  ▟███▛     ",
            "          ▟███▛             ▜██▛ ▟███▛      ",
            "         ▟███▛               ▜▛ ▟███▛       ",
            "▟███████████▛                  ▟██████████▙ ",
            "▜██████████▛                  ▟███████████▛ ",
            "      ▟███▛ ▟▙               ▟███▛          ",
            "     ▟███▛ ▟██▙             ▟███▛           ",
            "    ▟███▛  ▜███▙           ▝▀▀▀▀            ",
            "    ▜██▛    ▜███▙ ▜██████████████████▛      ",
            "     ▜▛     ▟████▙ ▜████████████████▛       ",
            "           ▟██████▙       ▜███▙             ",
            "          ▟███▛▜███▙       ▜███▙            ",
            "         ▟███▛  ▜███▙       ▜███▙           ",
            "         ▝▀▀▀    ▀▀▀▀▘       ▀▀▀▘           ",
        }
        dashboard.section.header.opts.hl = "Comment"
        dashboard.section.buttons.val = {
            dashboard.button("e", "New file", function() vim.cmd.ene() end),
            dashboard.button("q", "Quit", function() vim.cmd.qa({ bang = true }) end),
        }

        alpha.setup(dashboard.opts)
    end
}
