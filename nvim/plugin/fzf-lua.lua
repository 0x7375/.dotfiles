if vim.g.vscode then
  return
end

local fzf = require("fzf-lua")
local fzf_borders = require("util.fzf-borders")

local no_preview_winopts = { preview = { hidden = true } }

fzf.setup({
  actions = {
    files = {
      ["default"] = function(selected, opts)
        require("fzf-lua.actions").file_edit_or_qf(selected, opts)
        if #selected > 1 then
          vim.schedule(function() pcall(vim.cmd, "cfirst") end)
        end
      end,
      ["ctrl-s"] = fzf.actions.file_split,
      ["ctrl-v"] = fzf.actions.file_vsplit,
    },
  },
  fzf_opts = {
    -- ["--layout"] = "reverse",
  },
  previewers = {
    builtin = {
      syntax_limit_b = 1024 * 500,
    },
  },
  keymap = {
    builtin = {
      ["<C-a>"] = "toggle-fullscreen",
      ["<C-i>"] = "toggle-preview",
      ["<C-d>"] = "preview-page-down",
      ["<C-u>"] = "preview-page-up",
    },
    fzf = {
      ["alt-a"] = "toggle-all+accept",
    },
  },
  defaults = {
    header = false,
    formatter = "path.filename_first",
    git_icons = false,
  },
  winopts = {
    height = 0.9,
    width = vim.fn.round(vim.o.columns * 0.9),
    -- row = 0.5,
    backdrop = 100,
    preview = {
      title = false,
      scrollbar = false,
      layout = "horizontal",
      horizontal = "right:50%",
      -- vertical = "up:70%",
      border = fzf_borders.preview_border,
      winopts = {
        number = false,
      },
    },
    border = fzf_borders.main_border,
  },
  files = { winopts = no_preview_winopts },
  buffers = { winopts = no_preview_winopts },
  registers = { winopts = no_preview_winopts },
  lsp = {
    code_actions = {
      previewer = "codeaction",
    },
    symbols = { winopts = no_preview_winopts },
  },
  diagnostics = { winopts = no_preview_winopts },
  oldfiles = {
    include_current_session = true,
    winopts = no_preview_winopts,
  },
  file_ignore_patterns = {
    "%.o$",
    "%.jar$",
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
    ".obsidian/",
    ".stignore",
    ".stversions/",
    ".stfolder/",
    ".Trash-1000/",
  },
})

fzf.register_ui_select()

map("n", "<leader>p<esc>", "<nop>")
map("n", "<leader>pf", function() fzf.files() end, { desc = "Search for file" })
map("n", "<leader>pg", function() fzf.live_grep() end, { desc = "Search for string" })
map({ "n", "x" }, "<leader>pG", function() fzf.grep_cword() end, { desc = "Search for word under cursor" })
map("n", "<leader>ph", function() fzf.help_tags() end, { desc = "Search for help documentation" })
map("n", "<leader>pH", function() fzf.highlights() end, { desc = "Search for highlight groups" })
map("n", "<leader>pk", function() fzf.keymaps() end, { desc = "Search for keymaps" })
map("n", "<leader>pp", function() fzf.resume() end, { desc = "Resume last FzfLua search" })
map("n", "<leader>pb", function() fzf.buffers() end, { desc = "Search for buffers" })
map("n", "<leader>pq", function() fzf.oldfiles() end, { desc = "Search recently opened files" })
map("n", "<leader>pc", function() fzf.registers() end, { desc = "Search registers" })

map("n", "<leader>pd", function() fzf.lsp_document_diagnostics() end, { desc = "Search file diagnostics" })
map("n", "<leader>pD", function() fzf.lsp_workspace_diagnostics() end, { desc = "Search for workspace diagnostics" })
map("n", "<leader>pr", function() fzf.lsp_references() end, { desc = "Search for symbol references" })
map("n", "<leader>ps", function() fzf.lsp_document_symbols() end, { desc = "Search for file symbols" })
map("n", "<leader>pi", function() fzf.lsp_implementations() end, { desc = "Search for symbol implementations" })
map("n", "<leader>pI", function() fzf.lsp_incoming_calls() end, { desc = "Search for symbol incoming calls" })
map("n", "<leader>po", function() fzf.lsp_outgoing_calls() end, { desc = "Search for symbol outgoing calls" })
map("n", "<leader>pT", function() fzf.lsp_typedefs() end, { desc = "Search for type definitions" })
map("n", "<leader>pS", function() fzf.lsp_workspace_symbols() end, { desc = "Search for workspace symbols" })
map("n", "<leader>ca", function() fzf.lsp_code_actions() end, { desc = "Search code actions" })
