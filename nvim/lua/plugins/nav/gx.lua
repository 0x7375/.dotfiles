local opener = "xdg-open"
if vim.fn.has("mac") == 1 then
  opener = "open"
end

return {
  "chrishrb/gx.nvim",
  keys = {
    { "gx", vim.cmd.Browse, mode = { "n", "x" } },
  },
  cmd = "Browse",
  dependencies = { "nvim-lua/plenary.nvim" },
  submodules = false, -- not needed, submodules are required only for tests
  init = function() vim.g.netrw_nogx = 1 end,
  opts = {
    open_browser_app = opener,
    handlers = {
      plugin = true, -- open plugin links in lua (e.g. packer, lazy, ..)
      github = true, -- open github issues
      package_json = true, -- open dependencies from package.json
      search = true, -- search the web/selection on the web if nothing else is found
    },
  },
}
