-- Treesitter parser management for Neovim 0.12+
-- NOTE: Neovim 0.12+ has native treesitter highlighting/indentation.
-- This plugin is only used for parser installation (:TSInstall, :TSUpdate).
-- highlight.enable and indent.enable are DISABLED to avoid conflicts with
-- Neovim's built-in treesitter support (causes "attempt to call method 'range'" errors).
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	lazy = true,
	cmd = { "TSInstall", "TSUpdate", "TSUninstall" },
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"diff",
			"go",
			"html",
			"javascript",
			"json",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"python",
			"query",
			"rust",
			"toml",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		},
		auto_install = false,
		-- DISABLED: Neovim 0.12+ handles highlighting natively
		highlight = { enable = false },
		-- DISABLED: Neovim 0.12+ handles indentation natively
		indent = { enable = false },
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
