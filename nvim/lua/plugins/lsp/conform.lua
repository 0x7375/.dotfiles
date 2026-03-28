--             "efm-langserver",
--             "shellcheck",
--             -- "php84Packages.php-codesniffer",
--             "deno",
--             "typstyle",
--             "libxml2",
--             "shfmt",
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
      shfmt = {
        prepend_args = { "-i", "2", "-bn", "-ci", "-sr" },
      },
      deno_fmt = {
        prepend_args = { "--ext", "md" },
      },
    },
    format_on_save = function(bufnr)
      if vim.b[bufnr].disable_autoformat or vim.bo[bufnr].filetype == "markdown" then
        return
      end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
  },
  keys = {
    { "<leader>ff", function() vim.lsp.buf.format({ async = true }) end,                    desc = "Format file" },
    { "<leader>fd", function() vim.b.disable_autoformat = not vim.b.disable_autoformat end, desc = "Toggle auto formatting" }
  },
}
