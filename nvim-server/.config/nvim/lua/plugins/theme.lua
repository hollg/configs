return {
	lazy = false,
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "mocha",
			transparent_background = false,
			term_colors = false,
			no_italic = false,
			no_bold = false,
			no_underline = false,
			styles = {
				comments = { "italic" },
				conditionals = { "italic" },
			},
			integrations = {
				cmp = true,
				treesitter = true,
				mini = { enabled = true },
				mason = true,
				telescope = { enabled = true },
				which_key = true,
			},
		})
		vim.cmd.colorscheme("catppuccin-mocha")
	end,
}
