return {
	"nvim-neotest/neotest",
	keys = {
		{
			"<leader>nr",
			function()
				require("neotest").run.run()
			end,
			desc = "[r]un the nearest test",
		},
		{
			"<leader>nf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "run tests in [f]ile",
		},
		{
			"<leader>na",
			function()
				require("neotest").run.run({ suite = true })
			end,
			desc = "run [a]ll tests",
		},
		{
			"<leader>ns",
			function()
				require("neotest").run.stop()
			end,
			desc = "[s]top test",
		},
		{
			"<leader>nd",
			function()
				require("neotest").run.run({ strategy = "dap" })
			end,
			desc = "[d]ebug nearest test",
		},
		{
			"<leader>nn",
			function()
				require("neotest").run.attach()
			end,
			desc = "[a]ttach to nearest test",
		},
		{
			"<leader>no",
			function()
				require("neotest").output.open()
			end,
			desc = "show test [o]utput",
		},
		{
			"<leader>np",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "toggle output [p]anel",
		},
		{
			"<leader>nv",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "toggle summary",
		},
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-vitest"),
				require("neotest-golang"),
				require("rustaceanvim.neotest"),
			},
		})
	end,
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"marilari88/neotest-vitest",
		{ "fredrikaverpil/neotest-golang", version = "*" },
		"mrcjkb/rustaceanvim",
	},
}
