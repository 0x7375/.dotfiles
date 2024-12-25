return {
    'lewis6991/gitsigns.nvim',
    event = "User InGitRepo",
    keys = {
        { '[h', desc = "Goto previous git change" },
        { ']h', desc = "Goto next git change" },
        { 'gb', desc = "Toggle git blame" },
        { 'gh', desc = "Preview git change" },
    },
    opts = {
        signs = {
            add          = { text = "│" },
            change       = { text = "│" },
            delete       = { text = '_' },
            topdelete    = { text = "‾" },
            changedelete = { text = "~" },
            untracked    = { text = "│" },
        },
        on_attach = function(bufnr)
            local gitsigns = require("gitsigns");

            vim.keymap.set('n', '[h', function()
                gitsigns.prev_hunk({ buffer = bufnr })
                gitsigns.preview_hunk({ buffer = bufnr })
            end, { buffer = bufnr })

            vim.keymap.set('n', ']h', function()
                gitsigns.next_hunk({ buffer = bufnr })
                gitsigns.preview_hunk({ buffer = bufnr })
            end, { buffer = bufnr })

            vim.keymap.set('n', 'gb', gitsigns.toggle_current_line_blame, { buffer = bufnr })
            vim.keymap.set('n', 'gh', gitsigns.preview_hunk_inline, { buffer = bufnr })
        end,
    },
}
