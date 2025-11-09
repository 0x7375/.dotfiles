return {
    "nvim-telescope/telescope.nvim",
    cond = false,
    keys = {
        { "<leader>pu", function() vim.cmd.Telescope("undo") end, desc = "Search undo tree" },
        { "<leader>`",  function() vim.cmd.Telescope("lazy") end, desc = "Search lazy plugins" },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "debugloop/telescope-undo.nvim",
        "tsakirist/telescope-lazy.nvim",
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = not vim.g.windows }
    },
    opts = {
        defaults = {
            path_display = { "filename_first" },
            prompt_title = "",
            results_title = "",
            selection_caret = "▌ ",
            entry_prefix = '  ',
        },
        pickers = {
            find_files = {
                theme = "dropdown",
            },
        },
        extensions = {
            ---@module "telescope._extensions.lazy"
            ---@type TelescopeLazy.Config
            lazy = {
                theme = "dropdown",
                actions_opts = {
                    open_in_browser = {
                        auto_close = true,
                    },
                    change_cwd_to_plugin = {
                        auto_close = true,
                    },
                },
            },
            undo = {
                theme = "dropdown",
                previewer = true,
                prompt_prefix = "Undo> ",
            },
        },
    },
    config = function(_, opts)
        local actions = require('telescope.actions')
        local actions_layout = require('telescope.actions.layout')

        local toggle_fullscreen = require("util.custom_picker").toggle_fullscreen
        opts.defaults.create_layout = require("util.custom_picker").create_layout

        opts.defaults.mappings = {
            i = {
                ["<C-f>"] = actions.preview_scrolling_down,
                ["<C-b>"] = actions.preview_scrolling_up,
                ["<Tab>"] = actions_layout.toggle_preview,
                ["<C-a>"] = toggle_fullscreen,
                ["<ESC>"] = actions.close,
            },
            n = {
                ["<Tab>"] = actions_layout.toggle_preview,
                ["<C-a>"] = toggle_fullscreen,
            }
        }

        local undo = require('telescope-undo.actions')
        opts.extensions.undo.mappings = {
            i = {
                ["<C-y>"] = undo.yank_additions,
                ["<C-d>"] = undo.yank_deletions,
                ["<C-r>"] = undo.restore,
                ["<CR>"] = undo.restore,
            },
        }
        require("telescope").setup(opts)
        if not vim.g.windows then
            require("telescope").load_extension("fzf")
        end
        require("telescope").load_extension("undo")
        require("telescope").load_extension("lazy")
    end,
}
