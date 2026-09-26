return {
	"echasnovski/mini.completion",
	event = "InsertEnter",
	config = function()
		require("mini.completion").setup({
			lsp_completion = {
				source_func = "omnifunc",
				auto_setup = true,
			},
			fallback = {
				keyword = "<C-n>",
				keyword_func = function()
					vim.fn.complete(vim.fn.col("."), vim.fn.getcompletion("", "cmdline"))
				end,
			},
		})

		vim.keymap.set("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
		vim.keymap.set("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
		vim.keymap.set("i", "<CR>", [[pumvisible() ? "\<C-y>" : "\<CR>"]], { expr = true })
	end,
}
