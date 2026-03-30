return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Snippets select mode mappings
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node

    ls.add_snippets("typst", {
      s("o", {
        t("ol("),
        i(1),
        t(") "),
        i(0),
      }),
    })

    ls.add_snippets("php", {
      s("php", {
        t({ "<?php declare(strict_types=1);", "", "" }),
      }),
    })

    ls.add_snippets("javascript", {
      s("log", {
        t('console.log("'),
        i(0),
        t('");'),
      }),
    })

    vim.keymap.set({ "i" }, "<C-j>", function()
      if ls.expand_or_jumpable() then
        ls.expand_or_jump()
      end
    end, { silent = true, desc = "Jump or expand in snippet" })

    vim.keymap.set({ "s" }, "<C-j>", function() ls.jump(1) end, { silent = true, desc = "Jump to next snippet node" })
    vim.keymap.set(
      { "i", "s" },
      "<C-k>",
      function() ls.jump(-1) end,
      { silent = true, desc = "Jump to previous snippet node" }
    )
    vim.keymap.set({ "i", "s" }, "<C-e>", function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, { silent = true, desc = "Change snippet active choice" })
  end,
}
