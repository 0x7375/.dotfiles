return {
    "epwalsh/obsidian.nvim",
    build = "mkdir -p ~/notes",
    version = "*", -- recommended, use latest release instead of latest commit
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
    --   "BufReadPre path/to/my-vault/**.md",
    --   "BufNewFile path/to/my-vault/**.md",
    -- },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        workspaces = {
            {
                name = "notes",
                path = "~/notes",
            },
        },
        picker = {
            name = "fzf-lua",
        },
        follow_url_func = function(url)
            vim.fn.jobstart({ "xdg-open", url })
        end,
        ui = {
            enable = true,
            hl_groups = {
                ObsidianTodo = { link = "GruvboxOrange" },
                ObsidianRightArrow = { link = "GruvboxOrange" },
                ObsidianBullet = { link = "GruvboxOrange" },
                ObsidianTilde = { link = "GruvboxRed" },
                ObsidianDone = { link = "GruvboxBlue" },
                ObsidianRefText = { link = "GruvboxBlue" },
                ObsidianExtLinkIcon = { link = "GruvboxBlue" },
                ObsidianTag = { link = "GruvboxAqua" },
                ObsidianBlockID = { link = "GruvboxGrey" },
                ObsidianHighlightText = { link = "GruvboxYellow" },
            },
        },
    },
}
