return {
	{
		"yetone/avante.nvim",
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		-- ⚠️ must add this setting! ! !
		build = "make",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		---@module 'avante'
		---@type avante.Config
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"echasnovski/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"stevearc/dressing.nvim", -- for input provider dressing
			"folke/snacks.nvim", -- for input provider snacks
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			{
				"zbirenbaum/copilot.lua",
				cmd = "Copilot",
				event = "InsertEnter",
				config = function()
					require("copilot").setup({})
				end,
			},
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		opts = {
			-- add any opts here
			provider = "copilot",
			providers = {},
			-- mappings = {
			-- 	-- Disable Ctrl+n/p for history navigation to allow completion navigation
			-- 	history = {
			-- 		next = false, -- disable <C-n>
			-- 		prev = false, -- disable <C-p>
			-- 	},
			-- },
			-- system_prompt as function ensures LLM always has latest MCP server state
			-- This is evaluated for every message, even in existing chats
			system_prompt = function()
				local hub = require("mcphub").get_hub_instance()
				return hub and hub:get_active_servers_prompt() or ""
			end,
			-- Using function prevents requiring mcphub before it's loaded
			custom_tools = function()
				return { require("mcphub.extensions.avante").mcp_tool() }
			end,
		},
		disabled_tools = {
			"list_files", -- Built-in file operations
			"search_files",
			"read_file",
			"create_file",
			"rename_file",
			"delete_file",
			"create_dir",
			"rename_dir",
			"delete_dir",
			"bash", -- Built-in terminal access
		},
	},
	{
		"ravitemer/mcphub.nvim",
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
}
