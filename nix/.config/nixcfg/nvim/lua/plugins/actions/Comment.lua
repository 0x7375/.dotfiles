return {
    {
        'numToStr/Comment.nvim',
        cond = not vim.g.pi,
        keys = {
            { mode = { "x", "n" }, "gc", desc = "Comment/Uncomment" }
        },
        ---@module "Comment"
        ---@class CommentConfig
        config = function()
            require("Comment").setup({
                pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
            })
        end,
    }
}
