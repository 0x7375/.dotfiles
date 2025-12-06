return {
    "yetone/avante.nvim",
    build = "make",
    cond = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        {
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
    version = false,
    opts = {
        provider = "gemini",
        providers = {
            gemini = {
                model = "gemini-3-pro-preview",
                timeout = 30000,
                temperature = 0,
            },
        },
    },
}
