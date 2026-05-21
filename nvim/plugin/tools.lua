if vim.g.vscode then
  return
end

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "peek.nvim" and (kind == "install" or kind == "update") then
      local dir = vim.fn.stdpath("data") .. "/site/pack/core/opt/peek.nvim"
      vim.system({ "deno", "task", "--quiet" }, { cwd = dir }, function(obj)
        if obj.code ~= 0 then
          vim.notify("peek.nvim build failed:\n" .. obj.stderr, vim.log.levels.ERROR)
        else
          vim.notify("peek.nvim built successfully", vim.log.levels.INFO)
        end
      end)
    end
  end,
})

-- markdown preview
on_filetype("markdown", function()
  pack({ "toppair/peek.nvim" })
  local peek = require("peek")

  peek.setup({ app = "browser" })

  map("n", "<leader>wo", function() peek.open() end, { desc = "Open markdown preview" })
  map("n", "<leader>wc", function() peek.close() end, { desc = "Close markdown preview" })
end)

-- diff view
vim.api.nvim_create_user_command("CodeDiff", function()
  pack({ "esmuellert/codediff.nvim" })
  require("codediff").setup({})
  vim.cmd.CodeDiff()
end, {})

-- git ui
pack({ "tpope/vim-fugitive" })
map("n", "<leader>g", function() vim.cmd("tab Git") end, { desc = "Open fugitive" })

-- workspace search/replace
pack({ "MagicDuck/grug-far.nvim" })
map("n", "<leader>R", vim.cmd.GrugFar, { desc = "Search and replace project" })

-- live preview norm
pack({ "smjonas/live-command.nvim" })
require("live-command").setup({
  inline_highlighting = false,
  commands = {
    Norm = { cmd = "norm" },
  },
})
vim.cmd("cnoreabbrev norm Norm")

-- better undotree
pack({ "jiaoshijie/undotree" })
map("n", "<leader>u", function() require("undotree").toggle() end)
