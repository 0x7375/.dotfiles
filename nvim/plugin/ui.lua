if vim.g.vscode then
  return
end

-- hide secrets
pack({ "laytan/cloak.nvim" })
require("cloak").setup()

-- git symbols in column
pack({ "lewis6991/gitsigns.nvim" })

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

pack({ "rachartier/tiny-cmdline.nvim" })

require("tiny-cmdline").setup({
  width = {
    value = "40%",
  },

  position = {
    x = "50%",
    y = "20%",
  },
  menu_col_offset = 0,
  native_types = {},
})

-- experimental ui that avoid hit-enter prompts, g< to open buffer
-- https://www.reddit.com/r/neovim/comments/1sfmgkb/comment/oeyrgua/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
require("vim._core.ui2").enable({
  enable = true,
  msg = {
    targets = {
      [""] = "msg",
      empty = "cmd",
      bufwrite = "msg",
      confirm = "cmd",
      emsg = "pager",
      echo = "msg",
      echomsg = "msg",
      echoerr = "pager",
      completion = "cmd",
      list_cmd = "pager",
      lua_error = "pager",
      lua_print = "msg",
      progress = "pager",
      rpc_error = "pager",
      quickfix = "msg",
      search_cmd = "cmd",
      search_count = "cmd",
      shell_cmd = "pager",
      shell_err = "pager",
      shell_out = "pager",
      shell_ret = "msg",
      undo = "msg",
      verbose = "pager",
      wildlist = "cmd",
      wmsg = "msg",
      typed_cmd = "cmd",
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

-- show messages in the top left
-- local ui2 = require("vim._core.ui2")
-- local msgs = require("vim._core.ui2.messages")
--
-- local orig_set_pos = msgs.set_pos
-- msgs.set_pos = function(tgt)
--   orig_set_pos(tgt)
--   if (tgt == "msg" or tgt == nil) and vim.api.nvim_win_is_valid(ui2.wins.msg) then
--     pcall(vim.api.nvim_win_set_config, ui2.wins.msg, {
--       relative = "editor",
--       anchor = "NE",
--       row = 1,
--       col = vim.o.columns - 1,
--       border = "single",
--       width = math.min(vim.api.nvim_win_get_width(ui2.wins.msg), 30),
--     })
--   end
-- end

-- TODO: check if still needed in august ig, uncomment and test if it's getting cleared
-- vim.api.nvim_create_user_command("DoesItClearIt", function()
--   vim.cmd("echomsg 'Hellooooooo'")
--   vim.defer_fn(function() vim.cmd("echo ''") end, 100)
-- end, {})

-- ignore clear event so vim-fugitive for example leaves the output to be read
-- msgs.msg_clear = function() end

-- colorize
pack({ "brenoprata10/nvim-highlight-colors" })
require("nvim-highlight-colors").setup()
