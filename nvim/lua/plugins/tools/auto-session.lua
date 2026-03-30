return {
  "rmagatti/auto-session",
  cond = true,
  lazy = false,
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { "~/", "~/downloads", "/", "~/.cache" },
    bypass_save_filetypes = { "alpha" },
    pre_save_cmds = {
      -- save copilot chat
      function()
        local status, chat = pcall(require, "CopilotChat")
        if not status then
          return
        end

        if chat.response() or vim.g.copilot_chat_has_history then
          local hash = vim.fn.sha256(vim.fn.getcwd())
          chat.save(hash)
        end
      end,
      -- delete buffers except current and alternate one
      function()
        local current_buf = vim.api.nvim_get_current_buf()
        local alternate_buf = vim.fn.bufnr("#")

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local is_empty = #lines == 1 and lines[1] == ""

          if is_empty or (vim.fn.buflisted(buf) ~= 0 and buf ~= current_buf and buf ~= alternate_buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end,
    },
    theme_conf = {
      -- border = true,
      -- layout_config = {
      --   width = 0.8, -- Can set width and height as percent of window
      --   height = 0.5,
      -- },
    },
  },
}
