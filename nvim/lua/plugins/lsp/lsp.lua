vim.lsp.enable({
  "lua_ls",
  "nixd",
  "phpactor",
  "clangd",
  "gopls",
  "jdtls",
  "pyright", "ruff",
  "sqls",
  "bashls", "efm",
  "ts_ls", "eslint",
  "html", "cssls", "emmet_language_server",
  "graphql",
  "intelephense", "phpactor",
  "jsonls",
  "yamlls",
  "taplo",
  "texlab",
})

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("lint").linters_by_ft = {
        sh = { "shellcheck" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
  --     preferred_servers = {
  --       markdown = {},
  --       php = { "phpactor", "emmet_language_server" },
  --       python = { "pyright", "ruff" }, -- pylsp
  --       sh = { "efm", "bashls" },
  --       nix = { "nixd" }
  --     },
  --     prefer_local = true,
  --     -- default_config = {
  --     --     on_attach = on_attach
  --     -- },
  --     configs = {
  --       nixd = {
  --         },
  --       },
  --       lua_ls = {
  --         on_attach = lspformat.on_attach,
  --         settings = {
  --           Lua = {
  --             diagnostics = {
  --               globals = { "vim" },
  --             },
  --             hint = {
  --               enable = true,
  --               arrayIndex = "Disable",
  --             },
  --           }
  --         },
  --       },
  --       emmet_language_server = {
  --         filetypes = {
  --           "php", "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss",
  --           "pug", "typescriptreact"
  --         },
  --         on_new_config = function(new_config)
  --           new_config.cmd = require("lazy-lsp").in_shell({
  --             "emmet-language-server",
  --           }, new_config.cmd)
  --         end,
  --       },
  --       clangd = { on_attach = lspformat.on_attach, },
  --       hls = { on_attach = lspformat.on_attach, },
  --       gopls = { on_attach = lspformat.on_attach, },
  --       sourcekit = { on_attach = lspformat.on_attach, },
  --       intelephense = {
  --         on_attach = lspformat.on_attach,
  --         on_init = function(client)
  --           client.server_capabilities.documentFormattingProvider = true
  --         end,
  --         settings = {
  --           intelephense = {
  --             format = {
  --               enable = true,
  --               braces = "k&r", -- "k&r", "allman", "psr12"
  --             },
  --           },
  --         },
  --         on_new_config = function(new_config)
  --           new_config.cmd = require("lazy-lsp").in_shell({
  --             "nodePackages.intelephense"
  --           }, new_config.cmd)
  --         end,
  --         on_new_config = function(new_config)
  --           new_config.cmd = require("lazy-lsp").in_shell({
  --           }, new_config.cmd)
  --         end,
  --       },
  --     },
  --   })
  -- end,
}
