return {
    "zbirenbaum/copilot.lua",
    cond = true,
    event = "VeryLazy",
    keys = {
        { mode = "i", "<M-k>",  desc = "Copilot: next suggestion" },
        { mode = "i", "<M-h>",  desc = "Copilot: dismiss suggestion" },
        { mode = "i", "<M-l>",  desc = "Copilot: accept suggestion" },
        { mode = "i", "<M-w>",  desc = "Copilot: accept word" },
        { mode = "i", "<M-e>",  desc = "Copilot: accept line" },
        { mode = "i", "<M-j>",  desc = "Copilot: previous suggestion" },
        { mode = "i", "<M-CR>", desc = "Copilot: open suggestions panel" },
    },
    opts = {
        panel = {
            enabled = true,
            auto_refresh = true,
            keymap = {
                jump_prev = "[[",
                jump_next = "]]",
                accept = "<CR>",
                refresh = "gr",
                open = "<M-CR>"
            },
            layout = {
                position = "bottom",
                ratio = 0.4
            },
        },
        suggestion = {
            enabled = true,
            auto_trigger = false,
            keymap = {
                accept = "<M-l>",
                accept_word = "<M-w>",
                accept_line = "<M-e>",
                next = "<M-k>",
                prev = "<M-j>",
                dismiss = "<M-h>",
            },
        },
        filetypes = {
            yaml = true,
            markdown = true,
            help = true,
            gitcommit = true,
            gitrebase = true,
            hgcommit = true,
            svn = true,
            cvs = true,
            ["."] = true,
        },
    },
}
