if vim.g.vscode then
  return
end

pack({ "stevearc/conform.nvim" })

map(
  "n",
  "<leader>ff",
  function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
  { desc = "Format file" }
)
map("n", "<leader>fd", function()
  vim.notify(
    string.format("%s formatting...", vim.b.disable_autoformat and "Enabling" or "Disabling"),
    vim.log.levels.INFO
  )
  vim.b.disable_autoformat = not vim.b.disable_autoformat
end, { desc = "Toggle auto formatting" })

require("conform").setup({
  formatters_by_ft = {
    xml = { "xmllint" },
    typst = { "typstyle" },
    sh = { "shfmt" },
    php = { "phpcbf" },
    -- TODO check if the prettier pr is merged
    markdown = { "deno_fmt" },
    lua = { "stylua" },
  },
  formatters = {
    typstyle = {
      prepend_args = { "--wrap-text" },
    },
  },
  format_on_save = function(bufnr)
    local excluded_ft = {
      "markdown",
      "java",
    }

    if vim.b[bufnr].disable_autoformat or vim.tbl_contains(excluded_ft, vim.bo[bufnr].filetype) then
      return
    end

    return { timeout_ms = 500, lsp_format = "fallback" }
  end,
})
