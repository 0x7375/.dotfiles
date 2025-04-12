return {
    "folke/noice.nvim",
    cond = true,
    tag = "v4.4.7", -- cmdline flickr on search otherwise
    event = "VeryLazy",
    opts = {
        presets = {
            command_palette = true,
        },
        routes = {
            {
                filter = {
                    event = "msg_show",
                    kind = "",
                    any = {
                        { find = "written" },
                        { find = "lines" },
                    },
                },
                opts = { skip = true },
            },
            {
                filter = {
                    find = "shellescaped",
                },
            },
        },
        popupmenu = {
            enabled = true,
        },
        messages = {
            enabled = false,
        },
        cmdline = {
            enabled = false,
            opts = {
                border = { style = 'single' },
            },
            format = {
                cmdline = { title = "", pattern = "^:", icon = "", lang = "vim" },
                search_down = { title = "", kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                search_up = { title = "", kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                filter = { title = "", pattern = "^:%s*!", icon = "$", lang = "bash" },
                lua = { title = "", pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = " ", lang = "lua" },
                help = { title = "", pattern = "^:%s*he?l?p?%s+", icon = "󰋖" },
            },
        },
        lsp = {
            progress = { enabled = false, },
            signature = {
                enabled = true,
                auto_open = false,
            },
            hover = { enabled = true },
            documentation = {
                opts = {
                    border = { style = 'single' },
                    position = { row = 2 },
                    size = {
                        max_height = 15,
                    },
                },
            },
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                -- https://github.com/folke/noice.nvim/issues/962
                -- ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
            },
        },
    },
    dependencies = {
        { "MunifTanjim/nui.nvim" },
        {
            'stevearc/dressing.nvim',
            opts = {
                input = {
                    border = "single",
                    relative = "editor"
                },
                select = {
                    backend = { "fzf_lua", "fzf", "nui", "builtin", "telescope" },
                    builtin = {
                        border = "single"
                    },
                    nui = {
                        border = {
                            style = "single"
                        }
                    }
                }
            },
        },
        {
            "rcarriga/nvim-notify",
            opts = {
                on_open = function(win)
                    vim.api.nvim_win_set_config(win, { border = "single" })
                end,
                background_colour = "NotifyBackground",
                render = "minimal",
                timeout = 1500,
                stages = "static",
            },
        },
    }
}
