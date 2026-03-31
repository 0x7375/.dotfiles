if vim.g.vscode or true then
  return
end

pack({
  "mfussenegger/nvim-dap",
  "mfussenegger/nvim-dap-python",
  "igorlfs/nvim-dap-view",
})

local dap = require("dap")

require("dap-view").setup()

map("n", "<leader>dc", function() dap.continue() end, { desc = "DAP Continue" })
map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
map("n", "<leader>di", function() dap.step_into() end, { desc = "DAP Step Into" })
map("n", "<leader>do", function() dap.step_over() end, { desc = "DAP Step Over" })
map("n", "<leader>dO", function() dap.step_out() end, { desc = "DAP Step Out" })
map("n", "<leader>dr", function() dap.repl.open() end, { desc = "DAP Open REPL" })
map("n", "<leader>dl", function() dap.run_last() end, { desc = "DAP Run Last" })

map("n", "<leader>du", vim.cmd.DapViewToggle, { desc = "DAP View Toggle" })

dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
}

dap.configurations.c = {
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
    args = {}, -- provide arguments if needed
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
  {
    name = "Select and attach to process",
    type = "gdb",
    request = "attach",
    program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
    pid = function()
      local name = vim.fn.input("Executable name (filter): ")
      return require("dap.utils").pick_process({ filter = name })
    end,
    cwd = "${workspaceFolder}",
  },
  {
    name = "Attach to gdbserver :1234",
    type = "gdb",
    request = "attach",
    target = "localhost:1234",
    program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
    cwd = "${workspaceFolder}",
  },
}

require("dap-python").setup("python3")

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = function() return "python" end,
  },
}
