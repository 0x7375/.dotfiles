return {
  "stevearc/conform.nvim",
  lazy = false,
  opts = {
    formatters_by_ft = {
      xml = { "xmllint" },
      typst = { "typstyle" },
      sh = { "shfmt" },
      php = { "phpcbf" },
      -- TODO check if the prettier pr is merged
      markdown = { "deno_fmt" },
    },
    formatters = {
      typstyle = {
        prepend_args = { "--wrap-text" },
      },
    },
    format_on_save = function(bufnr)
      local excluded_ft = {
        "markdown",
        "java"
      }

      if vim.b[bufnr].disable_autoformat or vim.tbl_contains(excluded_ft, vim.bo[bufnr].filetype) then
        return
      end

      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
  },
  keys = {
    { "<leader>ff", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, desc = "Format file" },
    { "<leader>fd", function() vim.b.disable_autoformat = not vim.b.disable_autoformat end,              desc = "Toggle auto formatting" }
  },
}
