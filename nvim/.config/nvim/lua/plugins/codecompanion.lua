return {
	"olimorris/codecompanion.nvim",
	opts = {
		strategies = {
			chat = { adapter = "copilot" },
			inline = { adapter = "copilot" },
			agent = { adapter = "copilot" },
		},
		interactions = {
			chat = {
				opts = {
					completion_provider = "blink",
				},
			},
		},
		prompt_library = {
			markdown = {
				dirs = {
					vim.fn.stdpath("config") .. "/prompts",
				},
			},
		},
		extensions = {
			mcphub = {
				callback = "mcphub.extensions.codecompanion",
				opts = {
					make_tools = true,
					show_server_tools_in_chat = true,
					add_mcp_prefix_to_tool_names = false,
					show_result_in_chat = true,
					format_tool = nil,
					make_vars = true,
					make_slash_commands = true,
				},
			},
		},
	},
	keys = {
		{
			"<leader>xn",
			"<cmd>CodeCompanionChat<cr>",
			desc = "[n]ew CodeCompanion chat",
		},
		{
			"<leader>xt",
			"<cmd>CodeCompanionChat Toggle<cr>",
			desc = "[t]oggle CodeCompanion chat",
		},
		{
			"<leader>xa",
			"<cmd>CodeCompanionActions<cr>",
			desc = "CodeCompanion [a]ctions",
		},
	},
	dependencies = {
		{
			"zbirenbaum/copilot.lua",
			cmd = "Copilot",
			opts = {},
		},
		{
			"bahaaza/mcphub.nvim",
			commit = "9a39887cb853fa7f902e3bdd2cb4911bc3219f96",
			dependencies = { "nvim-lua/plenary.nvim" },
			build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
			config = function()
				require("mcphub").setup({
					workspace = {
						enabled = true, -- Default: true
						look_for = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json" },
						reload_on_dir_changed = true, -- Auto-switch on directory change
						port_range = { min = 40000, max = 41000 }, -- Port range for workspace hubs
						get_port = nil, -- Optional function for custom port assignment
					},
					extensions = {
						avante = {
							make_slash_commands = true, -- make /slash commands from MCP server prompts
						},
					},
				})
			end,
		},
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "codecompanion" },
			},
			ft = { "markdown", "codecompanion" },
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-treesitter/nvim-treesitter",
			},
		},
		{
			"HakonHarnes/img-clip.nvim",
			opts = {
				filetypes = {
					codecompanion = {
						prompt_for_file_name = false,
						template = "[Image]($FILE_PATH)",
						use_absolute_path = true,
					},
				},
			},
		},
	},
}
