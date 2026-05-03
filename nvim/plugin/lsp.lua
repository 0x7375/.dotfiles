if vim.g.vscode then
  return
end

-- lsp
pack({ "neovim/nvim-lspconfig" })
require("lspconfig")

vim.lsp.enable({
  "lua_ls",
  "nixd",
  "hls",
  "clangd",
  "gopls",
  "jdtls",
  "pyright",
  "ruff",
  "sqls",
  "bashls",
  "ts_ls",
  "eslint",
  "html",
  "cssls",
  "emmet_language_server",
  "graphql",
  "intelephense",
  "phpactor",
  "jsonls",
  "yamlls",
  "taplo",
  "texlab",
  "sourcekit",
})

-- toggle virtual text
local vt_on = {
  virtual_text = { current_line = true },
  signs = true,
  underline = true,
  update_in_insert = false,
}

local vt_off = {
  virtual_text = false,
  underline = false,
  update_in_insert = false,
}

vim.diagnostic.config(vt_on)

map("n", "<leader>v", function()
  local enabled = vim.diagnostic.config().virtual_text
  if enabled then
    vim.diagnostic.config(vt_off)
  else
    vim.diagnostic.config(vt_on)
  end
  vim.notify(string.format("%s virtual text...", enabled and "Disabling" or "Enabling"), vim.log.levels.INFO)
end, { desc = "Toggle virtual text" })

-- toggle inlay hints
map("n", "<leader>h", function()
  local enabled = not vim.lsp.inlay_hint.is_enabled()
  vim.notify(string.format("%s inlay hints...", enabled and "Enabling" or "Disabling"), vim.log.levels.INFO)
  vim.lsp.inlay_hint.enable(enabled)
end, { desc = "Toggle inlay hints" })

-- non rounded and max size to 60 preview
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "single"
  opts.max_width = opts.max_width or 60
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

map("n", "gl", vim.diagnostic.open_float, { desc = "Open diagnostic float" })

local jump = vim.diagnostic.jump
map("n", "[d", function() jump({ count = -1, float = true }) end, { desc = "Go to previous diagnostic" })
map("n", "]d", function() jump({ count = 1, float = true }) end, { desc = "Go to next diagnostic" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gD", vim.lsp.buf.declaration, opts)
    map("n", "gI", vim.lsp.buf.implementation, opts)
    map("n", "gn", vim.lsp.buf.references, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map({ "i", "s" }, "<c-k>", vim.lsp.buf.signature_help, opts)

    map("n", "<leader>cr", function()
      local current_iskeyword = vim.opt.iskeyword:get()
      vim.opt.iskeyword:append("_")
      vim.lsp.buf.rename()
      vim.opt.iskeyword = current_iskeyword
    end, opts)
  end,
})

on_filetype("lua", function()
  pack({ "folke/lazydev.nvim" })
  require("lazydev").setup({
    library = {
      -- adds vim.uv typings when that word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  })
end)

-- lint
pack({ "mfussenegger/nvim-lint" })

require("lint").linters_by_ft = {
  sh = { "shellcheck" },
  nix = { "statix", "deadnix" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
  callback = function() require("lint").try_lint() end,
})
