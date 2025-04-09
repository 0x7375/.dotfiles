return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    keys = {
        { "gl", vim.diagnostic.open_float,                                        desc = "Open diagnostic float" },
        { "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, desc = "Go to previous diagnostic" },
        { "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,  desc = "Go to next diagnostic" },
    },
    init = function()
        require('lspconfig.ui.windows').default_options.border = 'single'

        -- local lspconfig = require("lspconfig")
        -- lspconfig.emmet_language_server.setup({
        --     filetypes = { "php", "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss", "pug", "typescriptreact" },
        -- })

        -- highlight line number with diagnostic color
        for _, diag in ipairs({ "Error", "Warn", "Info", "Hint" }) do
            vim.fn.sign_define("DiagnosticSign" .. diag, {
                text = "",
                texthl = "DiagnosticSign" .. diag,
                linehl = "",
                numhl = "DiagnosticSign" .. diag,
            })
        end

        local virtual_text_on = {
            virtual_text = true,
            signs = true,
            underline = true,
            update_in_insert = false,
        }

        local virtual_text_off = {
            virtual_text = false,
            signs = false,
            underline = false,
            update_in_insert = false,
        }

        vim.diagnostic.config(virtual_text_on)

        vim.keymap.set("n", "<leader>v", function()
            local current_value = vim.diagnostic.config().virtual_text
            if current_value then
                vim.diagnostic.config(virtual_text_off)
            else
                vim.diagnostic.config(virtual_text_on)
            end
        end, { desc = "Toggle virtual text" })

        local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = opts.border or 'single'
            opts.max_width = opts.max_width or 60
            return orig_util_open_floating_preview(contents, syntax, opts, ...)
        end

        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
                -- Enable completion triggered by <c-x><c-o>
                -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                local opts = { buffer = ev.buf }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', 'gn', vim.lsp.buf.references, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
                -- vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<leader>cr", function()
                    local current_iskeyword = vim.opt.iskeyword:get()
                    vim.opt.iskeyword:append("_")
                    vim.lsp.buf.rename()
                    vim.opt.iskeyword = current_iskeyword
                end, opts)
                -- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            end,
        })
    end
}
