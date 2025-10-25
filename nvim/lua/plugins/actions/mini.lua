return {
    'nvim-mini/mini.nvim',
    version = false,
    config = function()
        require("mini.move").setup({
            mappings = {
                left = 'H',
                right = 'L',
                down = 'J',
                up = 'K',

                line_left = 'H',
                line_right = 'L',
                line_down = 'J',
                line_up = 'K',
            },

            options = {
                reindent_linewise = false,
            },
        })

        require("mini.jump").setup({
            mappings = { repeat_jump = ":" },
            delay = { highlight = 0 },
        })
    end,
}
