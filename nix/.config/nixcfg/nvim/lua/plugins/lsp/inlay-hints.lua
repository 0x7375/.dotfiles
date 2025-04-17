return {
    "MysticalDevil/inlay-hints.nvim",
    event = "LspAttach",
    keys = {
        { "<leader>h", vim.cmd.InlayHintsToggle, desc = "Toggle inlay hints" }
    },
    dependencies = "neovim/nvim-lspconfig",
    opts = {
        commands = { enable = true },
        autocmd = { enable = false }
    },
    config = function(_, opts)
        require("inlay-hints").setup(opts)
    end
}
