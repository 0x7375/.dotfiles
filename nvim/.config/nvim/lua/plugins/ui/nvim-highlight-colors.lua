return {
    'brenoprata10/nvim-highlight-colors',
    ft = { "html", "lua", "css", "php", "nix" },
    event = { "BufReadPre *.conf" },
    opts = {
        render = "background",
    },
}
