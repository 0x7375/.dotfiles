return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' },
  version = '1.*',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    completion = {
      list = { selection = { preselect = true, auto_insert = false }, },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 50,
      },
      menu = {
        scrollbar = false,
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind" }
          },
        }
      },
    },
    signature = { enabled = true },
    cmdline = {
      -- keymap = { preset = 'inherit' },
      completion = { menu = { auto_show = true } },
    },
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        snippets = {
          score_offset = 3,
        },
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
      },
    },
    snippets = { preset = "luasnip" },
  },
  opts_extend = { "sources.default" }
}
