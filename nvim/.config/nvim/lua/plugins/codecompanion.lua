return {
	"olimorris/codecompanion.nvim",
	opts = {
		strategies = {
			chat = {
				adapter = "copilot",
				opts = {
					completion_provider = "blink",
				},
			},
			inline = { adapter = "copilot" },
			agent = { adapter = "copilot" },
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
			-- Fork pinned for codecompanion v19 compatibility — upstream
			-- ravitemer/mcphub.nvim only supports up to v18 as of 2026-06.
			-- f94e1c8 fixes editor_context location after codecompanion's
			-- migration to interactions.shared.editor_context.
			-- Requires the `mcp-hub` node binary to be installed globally:
			--   npm install -g mcp-hub@latest
			-- Not wired as a `build` hook because lazy runs in a non-interactive
			-- shell that doesn't source nvm. `:checkhealth kickstart` warns if
			-- the binary is missing.
			"bahaaza/mcphub.nvim",
			commit = "f94e1c8e1aea68c3f8f6df5cf51c752033584fd0",
			dependencies = { "nvim-lua/plenary.nvim" },
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
				-- nvim-treesitter removed: Neovim 0.12+ has native treesitter support
				-- and the archived plugin causes "attempt to call method 'range'" errors
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
