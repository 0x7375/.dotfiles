return {
  cond = false,
  "mfussenegger/nvim-dap",
  keys = {
    { "<leader>dc", function() require("dap").continue() end, desc = "DAP Continue" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP Toggle Breakpoint" },
    { "<leader>di", function() require("dap").step_into() end, desc = "DAP Step Into" },
    { "<leader>do", function() require("dap").step_over() end, desc = "DAP Step Over" },
    { "<leader>dO", function() require("dap").step_out() end, desc = "DAP Step Out" },
    { "<leader>dr", function() require("dap").repl.open() end, desc = "DAP Open REPL" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "DAP Run Last" },
  },
  dependencies = {
    {
      "mfussenegger/nvim-dap-python",
      cond = false,
    },
    {
      "igorlfs/nvim-dap-view",
      ---@module 'dap-view'
      ---@type dapview.Config
      opts = {},
      keys = {
        { "<leader>du", vim.cmd.DapViewToggle, desc = "DAP View Toggle" },
      },
    },
  },
  config = function()
    local dap = require("dap")
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

    -- require("dap-python").setup("python3")

    -- dap.configurations.python = {
    --     {
    --         type = 'python',
    --         request = 'launch',
    --         name = "Launch file",
    --         program = "${file}",
    --         pythonPath = function()
    --             return 'python'
    --         end,
    --     },
    -- }
  end,
}
