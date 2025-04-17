vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = vim.api.nvim_get_current_buf(),
    callback = function()
        vim.fn.jobstart("make", {
            detach = true
        })
    end
})
