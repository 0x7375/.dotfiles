return {
    "simnalamburt/vim-mundo",
    cmd = "MundoToggle",
    keys = {
        { "<leader>u", vim.cmd.MundoToggle, desc = "Toggle undo tree" }
    },
    init = function()
        vim.g.mundo_width = 26;
        -- vim.g.mundo_preview_height = 10;
        vim.g.mundo_header = 0;
        vim.g.mundo_preview_bottom = 1;
        vim.g.mundo_preview_delay = 0;
    end
}
