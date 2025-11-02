return {
    "sindrets/diffview.nvim",
    keys = {
        { "<leader>Df", vim.cmd.DiffviewFileHistory, desc = "Open diff view file history" },
        { "<leader>Dc", vim.cmd.DiffviewClose,       desc = "Close diff view" },
        { "<leader>Do", vim.cmd.DiffviewOpen,        desc = "Open diff view" }
    },
    opts = {
        use_icons = false,
        view = {
            merge_tool = {
                layout = "diff3_mixed",
            },
        },
    },
}
