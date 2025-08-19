return {
	"nvim-neotest/neotest",
	event = "BufEnter",
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-vitest"),
				require("rustaceanvim.neotest"),
				require("neotest-golang"),
			},
		})

		vim.keymap.set(
			"n",
			"<leader>nr",
			'<cmd>lua require("neotest").run.run()<cr>',
			{ desc = "[r]un the nearest test" }
		)

		vim.keymap.set(
			"n",
			"<leader>nf",
			'<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>',
			{ desc = "run tests in [f]ile" }
		)

		vim.keymap.set(
			"n",
			"<leader>na",
			'<cmd>lua require("neotest").run.run({suite = true})<cr>',
			{ desc = "run [a]ll tests" }
		)

		vim.keymap.set("n", "<leader>ns", '<cmd>lua require("neotest").run.stop()<cr>', { desc = "[s]top test" })
		vim.keymap.set(
			"n",
			"<leader>nd",
			'<cmd>lua require("neotest").run.run({strategy = "dap"})<cr>',
			{ desc = "[d]ebug nearest test" }
		)
		vim.keymap.set(
			"n",
			"<leader>nn",
			'<cmd>lua require("neotest").run.attach()<cr>',
			{ desc = "[a]ttach to nearest test" }
		)

		vim.keymap.set(
			"n",
			"<leader>no",
			'<cmd>lua require("neotest").output.open()<cr>',
			{ desc = "show test [o]utput" }
		)

		vim.keymap.set(
			"n",
			"<leader>np",
			'<cmd>lua require("neotest").output_panel.toggle()<cr>',
			{ desc = "toggle output [p]anel" }
		)

		vim.keymap.set(
			"n",
			"<leader>nv",
			'<cmd>lua require("neotest").summary.toggle()<cr>',
			{ desc = "toggle summary" }
		)
	end,
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"marilari88/neotest-vitest",
		{ "fredrikaverpil/neotest-golang", version = "*" }, -- Installation
	},
}
