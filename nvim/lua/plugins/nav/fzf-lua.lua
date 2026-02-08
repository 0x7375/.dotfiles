return {
    'ibhagwan/fzf-lua',
    cmd = "FzfLua",
    keys = {
        { "<leader>p<esc>", "<nop>" },
        { "<leader>pD",     function() vim.cmd.FzfLua("lsp_workspace_diagnostics") end, desc = "Search for workspace diagnostics" },
        { "<leader>pd",     function() vim.cmd.FzfLua("lsp_document_diagnostics") end,  desc = "Search file diagnostics" },
        { "<leader>pf",     function() vim.cmd.FzfLua("files") end,                     desc = "Search for file" },
        { "<leader>pg",     function() vim.cmd.FzfLua("live_grep") end,                 desc = "Search for string" },
        {
            mode = { "n", "x" },
            "<leader>pG",
            function()
                vim.cmd.FzfLua(
                    "grep_cword")
            end,
            desc = "Search for word under cursor"
        },
        { "<leader>ph", function() vim.cmd.FzfLua("help_tags") end,             desc = "Search for help documentation" },
        { "<leader>pH", function() vim.cmd.FzfLua("highlights") end,            desc = "Search for highlight groups" },
        { "<leader>pk", function() vim.cmd.FzfLua("keymaps") end,               desc = "Search for keymaps" },
        { "<leader>pp", function() vim.cmd.FzfLua("resume") end,                desc = "Resume last FzfLua search" },
        { "<leader>pr", function() vim.cmd.FzfLua("lsp_references") end,        desc = "Search for symbol references" },
        { "<leader>ps", function() vim.cmd.FzfLua("lsp_document_symbols") end,  desc = "Search for file symbols" },
        { "<leader>pi", function() vim.cmd.FzfLua("lsp_implementations") end,   desc = "Search for symbol implementations" },
        { "<leader>pI", function() vim.cmd.FzfLua("lsp_incoming_calls") end,    desc = "Search for symbol incoming calls" },
        { "<leader>po", function() vim.cmd.FzfLua("lsp_outgoing_calls") end,    desc = "Search for symbol outgoing calls" },
        { "<leader>pT", function() vim.cmd.FzfLua("lsp_typedefs") end,          desc = "Search for type definitions" },
        { "<leader>pS", function() vim.cmd.FzfLua("lsp_workspace_symbols") end, desc = "Search for workspace symbols" },
        { "<leader>pb", function() vim.cmd.FzfLua("buffers") end,               desc = "Search for buffers" },
        { "<leader>pq", function() vim.cmd.FzfLua("oldfiles") end,              desc = "Search recently opened files" },
        { "<leader>pc", function() vim.cmd.FzfLua("registers") end,             desc = "Search registers" },
        { "<leader>ca", function() vim.cmd.FzfLua("lsp_code_actions") end,      desc = "Search code actions" },
        -- { '<leader>pb', function()
        --     require('fzf-lua').lgrep_curbuf {
        --         winopts = {
        --             height = 0.6,
        --             width = 0.5,
        --             preview = { vertical = 'up:70%' },
        --         },
        --     }
        -- end }
    },
    init = function()
        require("fzf-lua").register_ui_select()
    end,
    opts = {
        fzf_opts = {
            ['--info'] = 'default',
            ['--layout'] = 'reverse',
        },
        previewers = {
            builtin = {
                syntax_limit_b = 1024 * 500, -- 500KB
            },
        },
        keymap = {
            builtin = {
                ['<C-/>'] = 'toggle-help',
                ['<C-a>'] = 'toggle-fullscreen',
                ['<C-i>'] = 'toggle-preview',
                ['<C-d>'] = 'preview-page-down',
                ['<C-u>'] = 'preview-page-up',
            },
            fzf = {
                ['alt-a'] = 'toggle-all+accept',
            },
        },
        winopts = {
            height = 0.7,
            width = 0.6,
            backdrop = 100,
            preview = {
                scrollbar = false,
                layout = 'vertical',
                vertical = 'up:70%',
                border = "single",
            },
            border = "single",
        },
        defaults = {
            header = false,
            formatter = "path.filename_first",
            git_icons = false,
        },
        lsp = {
            code_actions = {
                previewer = 'codeaction',
            },
        },
        oldfiles = {
            include_current_session = true,
        },
        file_ignore_patterns = {
            "%.o",
            "%.jar",
            "%.class$",
            "%.out$",
            "%.log$",
            "%.aux$",
            "%.toc$",
            "%.env$",
            "%.xcodeproj/",
            "%.xcassets/",
            ".expo/",
            ".DS_Store",
            "desktop.ini",
            ".localized",
            "doc/",
            ".cache/",
            "bin/",
        },
    }
}
