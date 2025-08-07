return {
	"mrcjkb/rustaceanvim",
	dependencies = "neovim/nvim-lspconfig",
	version = "^4", -- Recommended
	config = function()
		vim.g.rustaceanvim = {
			server = {
				on_attach = function()
					local bufnr = vim.api.nvim_get_current_buf()
					vim.keymap.set("n", "K", function()
						vim.cmd.RustLsp({ "hover", "actions" })
					end, { buffer = bufnr })
				end,
			},
		}
	end,
}
