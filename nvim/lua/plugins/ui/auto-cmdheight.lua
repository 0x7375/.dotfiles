return {
    "jake-stewart/auto-cmdheight.nvim",
    lazy = false,
    opts = {
        max_lines = 5,
        duration = 2,
        remove_on_key = true,
        -- always clear the cmdline after duration and key press.
        -- by default it will only happen when cmdheight changed.
        clear_always = false,
    }
}
