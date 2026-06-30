if vim.g.vscode then
  return
end

-- hide secrets
require("cloak").setup()

-- git symbols in column
require("gitsigns").setup({
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "│" },
  },
  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")

    vim.keymap.set("n", "[h", function()
      gitsigns.nav_hunk("prev")
      gitsigns.preview_hunk()
    end, { buffer = bufnr })

    vim.keymap.set("n", "]h", function()
      gitsigns.nav_hunk("next")
      gitsigns.preview_hunk()
    end, { buffer = bufnr })

    vim.keymap.set(
      "n",
      "gb",
      gitsigns.toggle_current_line_blame,
      { desc = "Show current line git blame", buffer = bufnr }
    )
    vim.keymap.set("n", "gh", gitsigns.preview_hunk, { desc = "Preview hunk", buffer = bufnr })
    vim.keymap.set("n", "gH", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline", buffer = bufnr })
    vim.keymap.set("n", "gs", gitsigns.stage_hunk, { desc = "Stage hunk", buffer = bufnr })
    vim.keymap.set("n", "gX", gitsigns.reset_hunk, { desc = "Reset hunk", buffer = bufnr })
  end,
})

-- experimental ui that avoid hit-enter prompts, g< to open buffer
require("vim._core.ui2").enable({
  enable = true,
  msg = {
    targets = {
      empty = "cmd",
      bufwrite = "cmd",
      undo = "cmd",
      confirm = "cmd",
      emsg = "cmd",
      completion = "cmd",
      search_cmd = "cmd",
      search_count = "cmd",
      wildlist = "cmd",
      typed_cmd = "cmd",

      echo = "msg",
      echomsg = "msg",
      lua_print = "msg",
      progress = "msg",
      quickfix = "msg",
      wmsg = "msg",
      shell_ret = "msg",

      echoerr = "cmd",
      list_cmd = "pager",
      lua_error = "pager",
      rpc_error = "pager",
      shell_cmd = "pager",
      shell_err = "pager",
      shell_out = "pager",
      verbose = "pager",
    },
    cmd = {
      height = 0.5,
    },
    dialog = {
      height = 0.5,
    },
    msg = {
      height = 0.3,
      timeout = 3000,
    },
    pager = {
      height = 0.5,
    },
  },
})

-- colorize
require("nvim-highlight-colors").setup()
