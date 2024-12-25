return {
    "chaoren/vim-wordmotion",
    cond = true,
    event = "VeryLazy",
    init = function()
        vim.g.wordmotion_spaces = {
            '-',
            '_',
            '\\.',
            '"',
            "'",
            '{',
            '}',
            '\\(',
            '\\)',
            '\\[',
            '\\]',
            ':',
            ';'
        }
    end,
}
