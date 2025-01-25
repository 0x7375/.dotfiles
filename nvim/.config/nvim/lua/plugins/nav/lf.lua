return {
    "0xayko/lf.nvim",
    dependencies = {
        "akinsho/toggleterm.nvim",
    },
    lazy = false,
    keys = {
        {
            "<leader>k",
            function() require("lf").start(vim.fn.getcwd()) end,
            desc = "Toggle lf",
            { noremap = true },
        },
        {
            "<leader>K",
            function() require("lf").start(vim.fn.expand('%:p:h')) end,
            desc = "Toggle lf in current file dir",
            { noremap = true },
        },
    },
    init = function()
        vim.g.lf_netrw = 1

        vim.api.nvim_create_autocmd("User", {
            pattern = "LfTermEnter",
            callback = function(a)
                vim.api.nvim_buf_set_keymap(a.buf, "t", "q", "q", { nowait = true })
                vim.api.nvim_buf_set_keymap(a.buf, "t", "<ESC>", "q", { nowait = true })
                vim.api.nvim_buf_set_keymap(a.buf, "t", "<C-y>", "q", { nowait = true })
            end,
        })
    end,
    ---@module "lf"
    ---@type Lf.Config
    opts = {
        default_action = "drop",
        default_cmd = "lf",
        winblend = 0,
        dir = "", -- directory where `lf` starts ('gwd' is git-working-directory)
        direction = "float",
        border = "single",
        height = vim.o.lines - 1 - vim.o.cmdheight,
        width = vim.o.columns,
        mappings = false,
        escape_quit = true,
        focus_on_open = true,
        default_file_manager = true,
        disable_netrw_warning = true,
    },
}
