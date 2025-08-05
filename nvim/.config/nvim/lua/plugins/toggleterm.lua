return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup({ direction = "float" })
		vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "[t]oggle [t]erminal" })
	end,
}
