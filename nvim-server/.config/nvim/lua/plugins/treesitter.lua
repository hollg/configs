return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master", -- frozen branch; main is incompatible rewrite
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		ensure_installed = {
			"bash",
			"json",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"toml",
			"vim",
			"vimdoc",
			"yaml",
		},
		auto_install = false,
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
		},
	},
}
