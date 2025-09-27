return {
    "CopilotC-Nvim/CopilotChat.nvim",
    cond = true,
    build = "make tiktoken",
    dependencies = {
        { "nvim-lua/plenary.nvim", branch = "master" },
        {
            "MeanderingProgrammer/render-markdown.nvim",
            dependencies = {
                'nvim-treesitter/nvim-treesitter'
            },
            ---@module 'render-markdown'
            ---@type render.md.UserConfig
            opts = {
                file_types = { "copilot-chat" },
                heading = {
                    enable = false,
                },
                render_modes = true,
            },
        },
    },
    cmd = { "CopilotChatToggle" },
    keys = {
        { "<leader>j", vim.cmd.CopilotChatToggle, desc = "Toggle CopilotChat window" },
        { "<C-c>",     vim.cmd.CopilotChatStop,   ft = "copilot-chat",               desc = "Stop CopilotChat generation" },
        {
            mode = { "x", "n" },
            "<leader>ccp",
            function()
                require("CopilotChat").select_prompt()
            end,
            desc = "Copilot chat picker",
        }
    },
    ---@module "CopilotChat"
    ---@class CopilotChat.config
    init = function()
        vim.api.nvim_create_autocmd('BufEnter', {
            pattern = 'copilot-*',
            callback = function()
                vim.opt_local.number = false
                vim.opt_local.relativenumber = false
                -- vim.opt_local.signcolumn = "no"
            end
        })
    end,
    opts = {
        highlight_selection = false,
        question_header = ' ~ User ',
        answer_header = ' ~ Copilot ',
        error_header = ' ~ Error ',
        show_folds = false,

        model = 'claude-3.7-sonnet-thought',
        show_help = false,
        auto_follow_cursor = false,
        log_level = "warn",
        chat_autocomplete = false,
        window = {
            title = "",
            layout = "float",
            width = 1,
            height = 1,
        },
        mappings = {
            close = {
                insert = "",
            },
            complete = {
                detail = 'Use @<Tab> or /<Tab> for options.',
                insert = '',
            },
            edit_last = {
                normal = 'gj',
            },
            -- defaults mappings
            -- close = {
            --     normal = 'q',
            --     insert = '<C-c>'
            -- },
            -- reset = {
            --     normal ='<C-l>',
            --     insert = '<C-l>'
            -- },
            -- submit_prompt = {
            --     normal = '<CR>',
            --     insert = '<C-s>'
            -- },
            -- accept_diff = {
            --     normal = '<C-y>',
            --     insert = '<C-y>'
            -- },
            -- yank_diff = {
            --     normal = 'gy',
            --     register = '"',
            -- },
            -- show_diff = {
            --     normal = 'gd'
            -- },
            -- show_system_prompt = {
            --     normal = 'gp'
            -- },
            -- show_user_selection = {
            --     normal = 'gs'
            -- },
        },
    },
    config = function(_, opts)
        if pcall(require, "auto-session") then
            --- Restore chat history if it exists
            local function restore_chat()
                local hash = vim.fn.sha256(vim.fn.getcwd())
                local file = vim.fn.expand("~/.local/share/nvim/copilotchat_history/" .. hash .. ".json")

                if vim.fn.filereadable(file) == 1 and not vim.g.copilot_chat_has_history then
                    require("CopilotChat").load(hash)
                    vim.g.copilot_chat_has_history = true
                    vim.fn.delete(file)
                end
            end

            vim.g.copilot_chat_has_history = false
            local chat = require("CopilotChat")
            local prev_reset = chat.reset
            chat.reset = function()
                vim.g.copilot_chat_has_history = false
                return prev_reset()
            end

            local prev_toggle = chat.toggle
            chat.toggle = function(...)
                restore_chat()
                return prev_toggle(...)
            end

            local prev_ask = chat.ask
            chat.ask = function(...)
                restore_chat()
                return prev_ask(...)
            end
        end

        require("CopilotChat").setup(opts)
    end
}
