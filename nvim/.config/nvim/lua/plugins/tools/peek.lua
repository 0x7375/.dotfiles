return {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    opts = {
        app = 'browser', -- 'webview', 'browser', string or a table of strings
    },
    keys = {
        { "<leader>wo", function() require("peek").open() end,  desc = "Open markdown preview" },
        { "<leader>wc", function() require("peek").close() end, desc = "Close markdown preview" },
    },
}
