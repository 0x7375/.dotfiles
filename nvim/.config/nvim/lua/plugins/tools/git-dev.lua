return {
    "moyiz/git-dev.nvim",
    keys = {
        {
            "<leader>or",
            function()
                local themes = require('telescope.themes')
                require("telescope").extensions.git_dev.recents(themes.get_dropdown())
            end,
            desc = "Search recent repositories"
        },
        {
            "<leader>oo",
            function()
                vim.ui.input({ prompt = "Repository name / URI: " }, function(repo)
                    if repo and repo ~= "" then
                        require("git-dev").open(repo)
                    end
                end)
            end,
            desc = "Open remote repository",
        }
    },
    opts = {
        floating_win_config = {
            border = "single",
        },
    },
}
