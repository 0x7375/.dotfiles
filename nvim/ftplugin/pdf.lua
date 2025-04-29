local filename = vim.fn.expand("%:p")
vim.fn.jobstart("zathura '" .. filename .. "' &", { detach = true })

vim.defer_fn(function()
    vim.cmd("silent! bd!")
end, 100)
