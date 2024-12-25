return {
    'gbprod/yanky.nvim',
    keys = {
        { 'Y',                 desc = "Copy line and highlight copied text" },
        { mode = { "x", "n" }, 'y',                                         desc = "Copy and highlight copied text" },
        { '=p',                "<Plug>(YankyPutAfterFilter)",               desc = "Paste and indent after cursor" },
        { '=P',                "<Plug>(YankyPutBeforeFilter)",              desc = "Paste and indent before cursor" }
    },
    opts = {
        highlight = {
            on_put = false,
            on_yank = true,
            timer = 150,
        },
    },
}
