return {
	"arnamak/stay-centered.nvim",
	lazy = false,
	config = function()
		require("stay-centered").setup({})
		vim.keymap.set("n", "<leader>tc", require("stay-centered").toggle, { desc = "[t]oggle auto-[c]entering" })
	end,
}
