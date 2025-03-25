return {
    'lewis6991/gitsigns.nvim',
    event = "User InGitRepo",
    keys = {
        { '[h', desc = "Goto previous hunk" },
        { ']h', desc = "Goto next hunk" },
        { 'gb', desc = "Toggle blame" },
        { 'gh', desc = "Preview hunk" },
        { 'gH', desc = "Reset hunk" },
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
            vim.keymap.set('n', 'gh', gitsigns.preview_hunk, { buffer = bufnr })
            vim.keymap.set('n', 'gH', gitsigns.preview_hunk_inline, { buffer = bufnr })
            vim.keymap.set('n', 'gX', gitsigns.reset_hunk, { buffer = bufnr })
        end,
    },
}
