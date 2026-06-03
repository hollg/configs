return {
	"mrcjkb/rustaceanvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"mason-org/mason.nvim",
	},
	version = "^4", -- Recommended
	config = function()
		local cfg = {
			server = {
				on_attach = function()
					local bufnr = vim.api.nvim_get_current_buf()
					vim.keymap.set("n", "K", function()
						vim.cmd.RustLsp({ "hover", "actions" })
					end, { buffer = bufnr })
				end,
			},
		}

		local ok, mason_registry = pcall(require, "mason-registry")
		if ok and mason_registry.is_installed("codelldb") then
			local install_root = vim.fn.expand("$MASON/packages/codelldb")
			local codelldb_path = install_root .. "/extension/adapter/codelldb"
			local liblldb_ext = (vim.uv or vim.loop).os_uname().sysname == "Darwin" and "dylib" or "so"
			if vim.fn.has("win32") == 1 then
				codelldb_path = codelldb_path .. ".exe"
				liblldb_ext = "dll"
			end
			local liblldb_path = install_root .. "/extension/lldb/lib/liblldb." .. liblldb_ext
			cfg.dap = {
				adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path),
			}
		end

		vim.g.rustaceanvim = cfg
	end,
}
