if vim.g.vscode then
  return
end

on_event("InsertEnter,CmdlineEnter", function()
  pack({
    { src = "saghen/blink.cmp", version = vim.version.range("1.*") },
    "rafamadriz/friendly-snippets",
  })

  -- opts_extend = { "sources.default" },

  -- dedup entries
  local original = require("blink.cmp.completion.list").show
  ---@diagnostic disable-next-line: duplicate-set-field
  require("blink.cmp.completion.list").show = function(ctx, items_by_source)
    local seen = {}
    local priority = { "lsp", "snippets", "path", "buffer", "lazydev" }

    if items_by_source.lsp then
      table.sort(items_by_source.lsp, function(a, b)
        if a.kind == 15 and b.kind ~= 15 then
          return true
        end
        return false
      end)
    end

    for _, id in ipairs(priority) do
      if items_by_source[id] then
        items_by_source[id] = vim
          .iter(items_by_source[id])
          :filter(function(item)
            if seen[item.label] then
              return false
            end
            seen[item.label] = true
            return true
          end)
          :totable()
      end
    end
    return original(ctx, items_by_source)
  end

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  require("blink.cmp").setup({
    completion = {
      list = { selection = { preselect = true, auto_insert = false } },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 50,
      },
      menu = {
        scrollbar = false,
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind" },
          },
        },
      },
    },
    signature = { enabled = true },
    cmdline = {
      -- keymap = { preset = 'inherit' },
      completion = { menu = { auto_show = true } },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = {
        lua = { inherit_defaults = true, "lazydev" },
      },
      providers = {
        lsp = {
          score_offset = 6,
        },
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
  })
end)
