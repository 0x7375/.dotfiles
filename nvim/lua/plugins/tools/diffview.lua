return {
	-- TODO: switch to "esmuellert/codediff.nvim"
	"sindrets/diffview.nvim",
	keys = {
		{ "<leader>Df", vim.cmd.DiffviewFileHistory, desc = "Open diff view file history" },
		{ "<leader>Dc", vim.cmd.DiffviewClose, desc = "Close diff view" },
		{ "<leader>Do", vim.cmd.DiffviewOpen, desc = "Open diff view" },
	},
	opts = {
		use_icons = false,
		view = {
			merge_tool = {
				layout = "diff3_mixed",
			},
		},
		hooks = {
			diff_buf_win_enter = function(_, _, ctx)
				if ctx.layout_name:match("^diff2") then
					if ctx.symbol == "a" then
						vim.opt_local.winhl = table.concat({
							"DiffAdd:DiffviewDiffAddAsDelete",
							"DiffDelete:DiffviewDiffDelete",
						}, ",")
					elseif ctx.symbol == "b" then
						vim.opt_local.winhl = table.concat({
							"DiffDelete:DiffviewDiffDelete",
						}, ",")
					end
				end
			end,
		},
	},
}
