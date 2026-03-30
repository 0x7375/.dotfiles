return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.lsp.enable({
        "lua_ls",
        "nixd",
        "hls",
        "phpactor",
        "clangd",
        "gopls",
        "jdtls",
        "pyright", "ruff",
        "sqls",
        "bashls",
        "ts_ls", "eslint",
        "html", "cssls", "emmet_language_server",
        "graphql",
        "intelephense", "phpactor",
        "jsonls",
        "yamlls",
        "taplo",
        "texlab",
        "sourcekit",
      })

      local map = vim.keymap.set

      -- toggle virtual text
      local virtual_text_on = {
        virtual_text = { current_line = true },
        signs = true,
        underline = true,
        update_in_insert = false,
      }

      local virtual_text_off = {
        virtual_text = false,
        underline = false,
        update_in_insert = false,
      }

      vim.diagnostic.config(virtual_text_on)

      map("n", "<leader>v", function()
        local current_value = vim.diagnostic.config().virtual_text
        if current_value then
          vim.diagnostic.config(virtual_text_off)
        else
          vim.diagnostic.config(virtual_text_on)
        end
      end, { desc = "Toggle virtual text" })


      -- non rounded and max size to 60 preview
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or 'single'
        opts.max_width = opts.max_width or 60
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      map("n", "gl", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
      map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end,
        { desc = "Go to previous diagnostic" })
      map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,
        { desc = "Go to next diagnostic" })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          map("n", "gd", vim.lsp.buf.definition, opts)
          map("n", "gD", vim.lsp.buf.declaration, opts)
          map('n', 'gI', vim.lsp.buf.implementation, opts)
          map('n', 'gn', vim.lsp.buf.references, opts)
          map("n", "K", vim.lsp.buf.hover, opts)
          map("n", "<leader>cr", function()
            local current_iskeyword = vim.opt.iskeyword:get()
            vim.opt.iskeyword:append("_")
            vim.lsp.buf.rename()
            vim.opt.iskeyword = current_iskeyword
          end, opts)
        end,
      })
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
  },
}
