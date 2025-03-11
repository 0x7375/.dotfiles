return {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    event = { "BufReadPost", "BufWritePost", "BufNewFile", "CmdlineEnter" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        'nvim-treesitter/nvim-treesitter-refactor',
        'JoosepAlviste/nvim-ts-context-commentstring',
        {
            "nvim-treesitter/playground",
            cmd = { "TSHighlightCapturesUnderCursor" },
        },
        {
            "HiPhish/rainbow-delimiters.nvim",
            config = function()
                require('rainbow-delimiters.setup').setup {
                    blacklist = {
                        "html",
                    },
                    highlight = {
                        "RainbowOrange",
                        "RainbowYellow",
                        "RainbowCyan",
                        "RainbowViolet",
                        "RainbowGreen",
                        "RainbowBlue",
                    },
                }
            end
        }
    },
    opts = {
        auto_install = true,
        highlight = {
            enable = true,
            disable = function(lang, buf)
                if vim.tbl_contains({ "csv" }, lang) then
                    return true
                end

                local max_filesize = 100 * 1024 -- 100 KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,
        },
        indent = { enable = true },
        refactor = {
            smart_rename = {
                enable = true,
                keymaps = {
                    smart_rename = "<leader>r",
                },
            },
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ['aa'] = '@parameter.outer',
                    ['ia'] = '@parameter.inner',
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ac'] = '@class.outer',
                    ['ic'] = '@class.inner',
                },
            },
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                    [']m'] = '@function.outer',
                    [']c'] = '@class.outer',
                },
                goto_next_end = {
                    [']M'] = '@function.outer',
                    [']C'] = '@class.outer',
                },
                goto_previous_start = {
                    ['[m'] = '@function.outer',
                    ['[c'] = '@class.outer',
                },
                goto_previous_end = {
                    ['[M'] = '@function.outer',
                    ['[C'] = '@class.outer',
                },
            },
            swap = {
                enable = true,
                swap_next = {
                    ['<leader>i'] = '@parameter.inner',
                },
                swap_previous = {
                    ['<leader>I'] = '@parameter.inner',
                },
            },
        },
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end
}
