return {
    "sindrets/diffview.nvim",
    keys = {
        { "<leader>df", vim.cmd.DiffviewFileHistory, desc = "Open diff view file history" },
        { "<leader>dc", vim.cmd.DiffviewClose,       desc = "Close diff view" },
        { "<leader>do", vim.cmd.DiffviewOpen,        desc = "Open diff view" }
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
