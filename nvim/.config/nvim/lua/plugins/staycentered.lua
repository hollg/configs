return {
	"arnamak/stay-centered.nvim",
	keys = {
		{
			"<leader>tc",
			function()
				require("stay-centered").toggle()
			end,
			desc = "[t]oggle auto-[c]entering",
		},
	},
	config = function()
		require("stay-centered").setup({})
	end,
}
