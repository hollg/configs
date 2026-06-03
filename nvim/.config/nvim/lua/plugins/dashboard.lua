return {
  event = "VimEnter",
	"goolord/alpha-nvim",
	opts = function()
		-- header
		local dashboard = require("alpha.themes.dashboard")
		dashboard.section.header.val = {
			"                                                    ",
			" ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
			" ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
			" ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
			" ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
			" ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
			" ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
			"                                                    ",
		}

		-- menu options
		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", "<cmd>ene<CR>"),
			dashboard.button("f", "󰱼  [f]ind files", "<cmd>Telescope find_files<CR>"),
			dashboard.button("g", "󰱼  search by [g]rep", "<cmd>Telescope live_grep<CR>"),
			dashboard.button("p", "󰐱  manage [p]lugins", "<cmd>Lazy<CR>"),
			dashboard.button("q", "󰗼  [q]uit", "<cmd>qa<CR>"),
		}

		-- footer
		dashboard.section.footer.val =
			{ "", "", '"It\'s all talk until the code runs"', "", "                  — Ward Cunningham" }
	end,
	config = function()
		require("alpha").setup(require("alpha.themes.dashboard").config)
	end,
}
