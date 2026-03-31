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
    vim.keymap.set("n", "gX", gitsigns.reset_hunk, { desc = "Reset hunk", buffer = bufnr })
  end,
})

-- lsp progress, vim.ui.input, notifications
pack({ "folke/snacks.nvim" })

---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
local progress = vim.defaulttable()
vim.api.nvim_create_autocmd("LspProgress", {
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
    if not client or type(value) ~= "table" then
      return
    end
    local p = progress[client.id]

    for i = 1, #p + 1 do
      if i == #p + 1 or p[i].token == ev.data.params.token then
        p[i] = {
          token = ev.data.params.token,
          msg = ("[%3d%%] %s%s"):format(
            value.kind == "end" and 100 or value.percentage or 100,
            value.title or "",
            value.message and (" **%s**"):format(value.message) or ""
          ),
          done = value.kind == "end",
        }
        break
      end
    end

    local msg = {} ---@type string[]
    progress[client.id] = vim.tbl_filter(function(v) return table.insert(msg, v.msg) or not v.done end, p)

    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    vim.notify(table.concat(msg, "\n"), "info", {
      id = "lsp_progress",
      title = client.name,
      opts = function(notif)
        notif.icon = #progress[client.id] == 0 and " "
          or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
      end,
    })
  end,
})

---@type snacks.Config
require("snacks").setup({
  styles = {
    notification_history = {
      backdrop = 100,
    },
  },
  input = {
    enabled = true,
    icon = "",
  },
  notifier = {
    padding = false,
    enabled = true,
    icons = {
      error = "",
      warn = "",
      info = "",
      debug = "",
      trace = "",
    },
  },
})
