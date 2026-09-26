return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "mason-org/mason.nvim", version = "^2.0.0", opts = {} },
			{ "mason-org/mason-lspconfig.nvim", version = "^2.0.0" },
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("server-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, {
							buffer = event.buf,
							desc = "LSP: " .. desc,
						})
					end

					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
					map("grr", vim.lsp.buf.references, "[G]oto [R]eferences")
					map("grd", vim.lsp.buf.definition, "[G]oto [D]efinition")
					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					map("gri", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
					map("grt", vim.lsp.buf.type_definition, "[G]oto [T]ype Definition")
					map("gO", vim.lsp.buf.document_symbol, "Open Document Symbols")
					map("gW", vim.lsp.buf.workspace_symbol, "Open Workspace Symbols")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method and client:supports_method("textDocument/inlayHint", event.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				virtual_text = { source = "if_many", spacing = 2 },
			})

			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
							diagnostics = { globals = { "vim" } },
						},
					},
				},
			}

			local ensure_installed = vim.tbl_keys(servers)
			vim.list_extend(ensure_installed, { "stylua" })

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			for server_name, server in pairs(servers) do
				vim.lsp.config(server_name, server)
			end

			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(servers),
			})
		end,
	},
}
