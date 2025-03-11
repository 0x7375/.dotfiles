local function is_nixos()
    local handle = io.popen("grep '^ID=' /etc/os-release | cut -d'=' -f2")
    local result
    if handle ~= nil then
        result = handle:read("*a")
        handle:close()
    end

    result = result:gsub("%s+", "") -- Remove any trailing/leading spaces or newlines
    return result == "nixos"
end

return {
    "dundalek/lazy-lsp.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    cond = is_nixos(),
    dependencies = {
        {
            "lukas-reineke/lsp-format.nvim",
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
        "folke/neodev.nvim",
    },

    config = function()
        local lspformat = require("lsp-format")
        lspformat.setup {}

        -- Use synchronous formatting when quitting and saving
        vim.cmd [[cabbrev wq execute "Format sync" <bar> wq]]
        vim.cmd [[cabbrev x execute "Format sync" <bar> x]]

        require("neodev").setup()
        require("lazy-lsp").setup({
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
                -- "intelephense",
            },
            preferred_servers = {
                markdown = {},
                -- python = { "pyright", "ruff server" },
                php = { "phpactor", "emmet_language_server" },
                -- python = { "pylsp" },
                sh = { "efm", "bashls" },
                nix = { "efm", "nixd" }
            },
            prefer_local = true,
            -- default_config = {
            --     on_attach = on_attach
            -- },
            configs = {
                nixd = {
                    on_init = function(client)
                        client.server_capabilities.documentFormattingProvider = false
                    end,
                    settings = {
                        nixd = {
                            nixpkgs = {
                                expr = "import (builtins.getFlake \"/home/ayko/.config/nix\").inputs.nixpkgs { }",
                            },
                            options = {
                                nixos = {
                                    expr =
                                    '(builtins.getFlake \"/home/ayko/.config/nix\").nixosConfigurations.yugen.options',
                                },
                                home_manager = {
                                    expr =
                                    '(builtins.getFlake \"/home/ayko/.config/nix\").homeConfigurations.\"ayko@yugen\".options',
                                },
                            },
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
                hls = {
                    on_attach = lspformat.on_attach,
                },
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
                    on_attach = lspformat.on_attach,
                    init_options = { documentFormatting = true, documentRangeFormatting = true },
                    filetypes = { "sh", "nix", "php", "markdown" },
                    settings = {
                        languages = {
                            nix = {
                                {
                                    formatCommand = "nixfmt",
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
                                    formatCommand = "prettier --parser markdown",
                                    formatStdin = true,
                                },
                            },
                        },
                    },
                    on_new_config = function(new_config)
                        new_config.cmd = require("lazy-lsp").in_shell({
                            "efm-langserver",
                            "shellcheck",
                            "nixfmt-rfc-style",
                            "php81Packages.php-codesniffer",
                            "nodePackages.prettier",
                        }, new_config.cmd)
                    end,
                },
            },
        })
    end,
}
