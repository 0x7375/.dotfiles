return {
  'hrsh7th/nvim-cmp',
  event = { "InsertEnter", "CmdlineEnter" },
  cond = false,
  dependencies = {
    'hrsh7th/cmp-buffer',
    'https://codeberg.org/FelipeLema/cmp-async-path.git',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lua',
    'saadparwaiz1/cmp_luasnip',
  },
  keys = {
    { mode = { "i" }, "<C-p>", "<nop>" },
    { mode = { "i" }, "<C-n>", "<nop>" },
  },
  opts = function()
    local cmp = require('cmp')
    local completion_opts = {
      border = "single",
      scrollbar = false,
      winhighlight = "Normal:NormalFloat,FloatBorder:Comment,CursorLine:PmenuSel",
    }

    return {
      default = {
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        formatting = {
          fields = { "abbr", "kind" },
          format = function(entry, vim_item)
            vim_item.abbr = vim_item.abbr:match("[^(]+")
            vim_item.menu = nil

            local source = entry.source.name
            if source == "luasnip" or source == "nvim_lsp" then
              vim_item.dup = 0
            end

            return vim_item
          end
        },
        window = {
          completion = cmp.config.window.bordered(completion_opts),
          documentation = cmp.config.window.bordered(completion_opts),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'async_path' },
          { name = 'nvim_lua' },
        }
      },
      cmdline = {
        mapping = cmp.mapping.preset.cmdline {
          ['<C-n>'] = cmp.config.disable,
          ['<C-p>'] = cmp.config.disable,
        },
        sources = cmp.config.sources {
          { name = 'async_path' },
          { name = 'cmdline' },
        },
        matching = { disallow_symbol_nonprefix_matching = false }
      },
      search = {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      },
    }
  end,
  config = function(_, opts)
    local cmd = require("cmp")

    cmd.setup(opts.default)
    cmd.setup.cmdline({ '/', '?' }, opts.search)
    cmd.setup.cmdline(':', opts.cmdline)
  end
}
