-- Remove new line comments behaviour on every file
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "java" then
      return
    end
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- comment vimv lines
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.env.VIMV then
      vim.api.nvim_set_option_value("commentstring", "# %s", { buf = 0 })
    end
  end,
})

-- delete lsp log file past 50MB
local log_path = vim.lsp.log.get_filename()
local stat = vim.uv.fs_stat(log_path)
if stat and stat.size > 50 * 1024 * 1024 then
  io.open(log_path, "w+"):close()
end

vim.filetype.add({ extension = { log = "log" } })
vim.filetype.add({ extension = { lock = "json" } })
vim.filetype.add({ extension = { g4 = "antlr4" } })
vim.filetype.add({ extension = { code = "c" } })

-- go to last loc when opening a buffer
local function augroup(name) return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true }) end

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- update winbar when needed
vim.api.nvim_create_autocmd({
  "BufEnter",
  "BufWritePost",
  "BufModifiedSet",

  "WinEnter",
  "VimEnter",

  "ModeChanged",
  "DirChanged",
  "RecordingEnter",
}, {
  callback = function() require("util.bar").refresh() end,
})
vim.api.nvim_create_autocmd("RecordingLeave", {
  callback = function()
    vim.schedule(function() require("util.bar").refresh() end)
  end,
})

-- set pwd to first argument if said argument is a directory
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 1 then
      local target = vim.fn.argv(0)
      if vim.fn.isdirectory(target) == 1 then
        vim.cmd("cd " .. vim.fn.fnameescape(target))
      end
    end
  end,
})

vim.api.nvim_create_autocmd("Signal", {
  group = vim.api.nvim_create_augroup("reload_theme_on_SIGUSR1", {}),
  pattern = "SIGUSR1",
  desc = "reload theme on SIGUSR1",
  callback = function() require("util.theme").update() end,
  nested = true,
})

-- open binary files with default application
local function open()
  local prev_buf = vim.fn.bufnr("%")
  local fn = vim.fn.expand("%:p")
  vim.ui.open(fn)
  print(string.format("Opening file: %s", fn))

  if vim.fn.buflisted(prev_buf) == 1 then
    vim.api.nvim_set_current_buf(prev_buf)
  end

  vim.api.nvim_buf_delete(0, { force = true })
end

local bin_files = vim.api.nvim_create_augroup("binFiles", { clear = true })

local file_types = {
  "pdf",
  "jpg",
  "jpeg",
  "webp",
  "png",
  "mp3",
  "mp4",
  "xls",
  "xlsx",
  "xopp",
  "gif",
  "doc",
  "docx",
  "gaphor",
}

for _, ext in ipairs(file_types) do
  vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
    pattern = "*." .. ext,
    group = bin_files,
    callback = open,
  })
end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  desc = "Highlight yanked text",
  pattern = "*",
  callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 }) end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Close with <q>",
  pattern = {
    "git",
    "help",
    "man",
    "qf",
    "scratch",
    "nvim-pack",
    "vim",
  },
  callback = function(args)
    if args.match ~= "help" or not vim.bo[args.buf].modifiable then
      vim.keymap.set("n", "q", "<cmd>quit<cr>", { buffer = args.buf })
    end
  end,
})

-- vim.api.nvim_create_autocmd("VimEnter", {
--   desc = "Open edited file on startup",
--   nested = true,
--   callback = function()
--     if vim.fn.argc() == 0 and vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
--       local last = vim.v.oldfiles[1]
--       if last and vim.fn.filereadable(last) == 1 then
--         vim.schedule(function() vim.cmd("edit " .. vim.fn.fnameescape(last)) end)
--       end
--     end
--   end,
-- })

vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    local value = ev.data.params.value
    vim.api.nvim_echo({ { value.message or "done" } }, false, {
      id = "lsp." .. ev.data.client_id,
      kind = "progress",
      source = "vim.lsp",
      title = value.title,
      status = value.kind ~= "end" and "running" or "success",
      percent = value.percentage,
    })
  end,
})
