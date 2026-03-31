local vscode = require("vscode")
local call = vscode.call

map("n", "<leader>e", function() call("workbench.action.toggleSidebarVisibility") end)
map("n", "<leader>t", function() call("workbench.actions.view.problems") end)
map("n", "<c-o>", function() call("workbench.action.navigateBack") end)
map("n", "<c-i>", function() call("workbench.action.navigateForward") end)
map("n", "<leader>f", function() call("editor.action.formatDocument") end)
map("n", "<leader>q", function() call("vscode-neovim.stop") end)
map("n", "<leader>ca", function() call("editor.action.quickFix") end)
map("n", "<leader>cr", function() call("editor.action.rename") end)
map("n", "[d", function() call("editor.action.marker.prev") end)
map("n", "]d", function() call("editor.action.marker.next") end)
map("n", "gl", function() call("editor.action.marker.next") end)
map("n", "gn", function() call("editor.action.referenceSearch.trigger") end)
map("n", "<leader>pq", function() call("workbench.action.openRecent") end)
map("n", "<leader>ps", function() call("workbench.action.gotoSymbol") end)
map("n", "<leader>pS", function() call("workbench.action.showAllSymbols") end)
map("n", "<leader>pg", function() call("workbench.action.findInFiles") end)
map("n", "<leader>pr", function() call("references-view.findReferences") end)
map("n", "<leader>pf", function() call("workbench.action.quickOpen") end)

vim.opt.cmdheight = 1
vim.notify = vscode.notify
