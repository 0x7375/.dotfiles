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
    init = function()
        -- https://github.com/gbprod/yanky.nvim/issues/37#issuecomment-1193671730

        -- remove if there are no errors for a month, 08/04
        -- vim.g.clipboard = {
        --     name = "xsel_override",
        --     copy = {
        --         ["+"] = "xsel --input --clipboard",
        --         ["*"] = "xsel --input --primary",
        --     },
        --     paste = {
        --         ["+"] = "xsel --output --clipboard",
        --         ["*"] = "xsel --output --primary",
        --     },
        --     cache_enabled = 1,
        -- }
    end,
}
