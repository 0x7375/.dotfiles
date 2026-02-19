local function has_nix()
  return vim.fn.executable('nix') == 1
end

return {
  "dundalek/lazy-lsp.nvim",
  cond = has_nix(),
  dependencies = {
    {
      "jfly/lsp-format.nvim",
      branch = "issue-95",
      keys = {
        { "<leader>ff", function() vim.lsp.buf.format({ async = true }) end, desc = "Format file" },
        { "<leader>fd", function() vim.cmd("FormatToggle") end,              desc = "Toggle auto formatting" }
      },
    },
    {
      'creativenull/efmls-configs-nvim',
      version = 'v1.x.x',
      dependencies = { 'neovim/nvim-lspconfig' },
    },
    {
      "folke/lazydev.nvim",
      ft = "lua",
    },
  },

  config = function()
    local lspformat = require("lsp-format")
    lspformat.setup {}

    -- Use synchronous formatting when quitting and saving
    vim.cmd [[cabbrev wq execute "Format sync" <bar> wq]]
    vim.cmd [[cabbrev x execute "Format sync" <bar> x]]

    require("lazy-lsp").setup({
      use_vim_lsp_config = true,
      excluded_servers = {
        "jedi_language_server",            -- exec not found
        "ccls",                            -- prefer clangd
        "denols",                          -- prefer eslint and tsserver
        "docker_compose_language_service", -- yamlls should be enough?
        "flow",                            -- prefer eslint and tsserver
        "ltex",                            -- grammar tool using too much CPU
        "quick_lint_js",                   -- prefer eslint and tsserver
        "rnix",                            -- archived on Jan 25, 2024
        "scry",                            -- archived on Jun 1, 2023
        "tailwindcss",                     -- associates with too many filetypes
        "pylyzer",                         -- throws many irrelevant errors
        "gdscript",                        -- doesn't exist?
        -- "intelephense",
      },
      preferred_servers = {
        markdown = {},
        php = { "phpactor", "emmet_language_server" },
        python = { "pyright", "ruff" }, -- pylsp
        sh = { "efm", "bashls" },
        nix = { "nixd" }
      },
      prefer_local = true,
      -- default_config = {
      --     on_attach = on_attach
      -- },
      configs = {
        nixd = {
          on_attach = lspformat.on_attach,
          cmd = { "nixd", "--semantic-tokens=true", "--inlay-hints=true" },
          settings = {
            settings = {
              nixd = (function()
                local flake = os.getenv("FLAKE")
                if not flake then
                  return
                end

                flake = "(builtins.getFlake \"" .. flake .. "\")"

                local uname = io.popen("uname"):read("*l")
                local sys = (uname == "Linux") and "nixos" or "darwin"

                local host = os.getenv("HOSTNAME")

                return {
                  nixpkgs = {
                    expr = string.format("import %s.inputs.nixpkgs { }", flake),
                  },
                  options = {
                    [sys] = {
                      expr = string.format('%s.%sConfigurations.%s.options', flake, sys, host),
                    },
                  },
                }
              end)(),
            },

          },
        },
        lua_ls = {
          on_attach = lspformat.on_attach,
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              hint = {
                enable = true,
                arrayIndex = "Disable",
              },
            }
          },
        },
        emmet_language_server = {
          filetypes = {
            "php", "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss",
            "pug", "typescriptreact"
          },
          on_new_config = function(new_config)
            new_config.cmd = require("lazy-lsp").in_shell({
              "emmet-language-server",
            }, new_config.cmd)
          end,
        },
        clangd = { on_attach = lspformat.on_attach, },
        hls = { on_attach = lspformat.on_attach, },
        gopls = { on_attach = lspformat.on_attach, },
        sourcekit = { on_attach = lspformat.on_attach, },
        intelephense = {
          on_attach = lspformat.on_attach,
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = true
          end,
          settings = {
            intelephense = {
              format = {
                enable = true,
                braces = "k&r", -- "k&r", "allman", "psr12"
              },
            },
          },
          on_new_config = function(new_config)
            new_config.cmd = require("lazy-lsp").in_shell({
              "nodePackages.intelephense"
            }, new_config.cmd)
          end,
        },
        efm = {
          on_attach = function(client, bufnr)
            -- don't auto format markdown
            if vim.bo[bufnr].filetype ~= "markdown" then
              lspformat.on_attach(client, bufnr)
            end
          end,
          init_options = { documentFormatting = true, documentRangeFormatting = true },
          filetypes = { "sh", "php", "markdown", "typst", "xml" },
          settings = {
            languages = {
              xml = {
                {
                  formatCommand = "xmllint --format -",
                  formatStdin = true,
                }
              },
              typst = {
                {
                  formatCommand = "typstyle --wrap-text",
                  formatStdin = true,
                }
              },
              sh = {
                {
                  lintCommand = "shellcheck -f gcc -x",
                  lintSource = "shellcheck",
                  lintFormats = { "%f:%l:%c: %trror: %m", "%f:%l:%c: %tarning: %m",
                    "%f:%l:%c: %tote: %m" },
                },
              },
              php = {
                {
                  formatCommand = "phpcbf - || true", -- see https://github.com/mattn/efm-langserver/issues/183
                  formatStdin = true,
                  rootMarkers = { "phpcs.xml", "composer.json" },
                },
              },
              markdown = {
                {
                  formatCommand = "deno fmt - --ext md",
                  formatStdin = true,
                },
              },
            },
          },
          on_new_config = function(new_config)
            new_config.cmd = require("lazy-lsp").in_shell({
              "efm-langserver",
              "shellcheck",
              -- "php84Packages.php-codesniffer",
              "deno",
              "typstyle",
              "libxml2",
            }, new_config.cmd)
          end,
        },
      },
    })
  end,
}
