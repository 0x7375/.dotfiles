if vim.g.vscode then
  return
end

pack({ "ibhagwan/fzf-lua" })

local fzf = require("fzf-lua")

fzf.setup({
  actions = {
    files = {
      ["default"] = function(selected, opts)
        require("fzf-lua.actions").file_edit_or_qf(selected, opts)
        if #selected > 1 then
          vim.schedule(function() pcall(vim.cmd, "cfirst") end)
        end
      end,
    },
  },
  fzf_opts = {
    ["--info"] = "default",
    ["--layout"] = "reverse",
  },
  previewers = {
    builtin = {
      syntax_limit_b = 1024 * 500,
    },
  },
  keymap = {
    builtin = {
      ["<C-/>"] = "toggle-help",
      ["<C-a>"] = "toggle-fullscreen",
      ["<C-i>"] = "toggle-preview",
      ["<C-d>"] = "preview-page-down",
      ["<C-u>"] = "preview-page-up",
    },
    fzf = {
      ["alt-a"] = "toggle-all+accept",
    },
  },
  winopts = {
    height = 0.7,
    width = 0.6,
    backdrop = 100,
    preview = {
      scrollbar = false,
      layout = "vertical",
      vertical = "up:70%",
      border = "single",
    },
    border = "single",
  },
  defaults = {
    header = false,
    formatter = "path.filename_first",
    git_icons = false,
  },
  lsp = {
    code_actions = {
      previewer = "codeaction",
    },
  },
  oldfiles = {
    include_current_session = true,
  },
  file_ignore_patterns = {
    "%.o",
    "%.jar",
    "%.class$",
    "%.out$",
    "%.log$",
    "%.aux$",
    "%.toc$",
    "%.env$",
    "%.xcodeproj/",
    "%.xcassets/",
    ".expo/",
    ".DS_Store",
    "desktop.ini",
    ".localized",
    "flake.lock",
    "doc/",
    ".cache/",
    "bin/",
  },
})

fzf.register_ui_select()

map("n", "<leader>p<esc>", "<nop>")
map("n", "<leader>pD", function() fzf.lsp_workspace_diagnostics() end, { desc = "Search for workspace diagnostics" })

map("n", "<leader>pd", function() fzf.lsp_document_diagnostics() end, { desc = "Search file diagnostics" })
map("n", "<leader>pf", function() fzf.files() end, { desc = "Search for file" })
map("n", "<leader>pg", function() fzf.live_grep() end, { desc = "Search for string" })
map({ "n", "x" }, "<leader>pG", function() fzf.grep_cword() end, { desc = "Search for word under cursor" })
map("n", "<leader>ph", function() fzf.help_tags() end, { desc = "Search for help documentation" })
map("n", "<leader>pH", function() fzf.highlights() end, { desc = "Search for highlight groups" })
map("n", "<leader>pk", function() fzf.keymaps() end, { desc = "Search for keymaps" })
map("n", "<leader>pp", function() fzf.resume() end, { desc = "Resume last FzfLua search" })
map("n", "<leader>pr", function() fzf.lsp_references() end, { desc = "Search for symbol references" })
map("n", "<leader>ps", function() fzf.lsp_document_symbols() end, { desc = "Search for file symbols" })
map("n", "<leader>pi", function() fzf.lsp_implementations() end, { desc = "Search for symbol implementations" })
map("n", "<leader>pI", function() fzf.lsp_incoming_calls() end, { desc = "Search for symbol incoming calls" })
map("n", "<leader>po", function() fzf.lsp_outgoing_calls() end, { desc = "Search for symbol outgoing calls" })
map("n", "<leader>pT", function() fzf.lsp_typedefs() end, { desc = "Search for type definitions" })
map("n", "<leader>pS", function() fzf.lsp_workspace_symbols() end, { desc = "Search for workspace symbols" })
map("n", "<leader>pb", function() fzf.buffers() end, { desc = "Search for buffers" })
map("n", "<leader>pq", function() fzf.oldfiles() end, { desc = "Search recently opened files" })
map("n", "<leader>pc", function() fzf.registers() end, { desc = "Search registers" })
map("n", "<leader>ca", function() fzf.lsp_code_actions() end, { desc = "Search code actions" })
-- map("n", "<leader>pb", function()
--   fzf.lgrep_curbuf {
--     winopts = {
--       height = 0.6,
--       width = 0.5,
--       preview = { vertical = "up:70%" },
--     },
--   }
-- end)
