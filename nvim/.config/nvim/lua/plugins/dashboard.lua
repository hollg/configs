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
			dashboard.button("e", "  New file", "<cmd>ene <CR>"),
			dashboard.button("SPC s f", "󰱼  [s]earch for a [f]ile"),
			dashboard.button("SPC s g", "󰱼  [s]earch by [g]rep"),
			dashboard.button("SPC m p", "󰐱  [m]anage [p]lugins", "<cmd>Lazy<CR>"),
			dashboard.button("q", "󰗼  Quit", ":qa<CR>"),
		}

		-- footer
		dashboard.section.footer.val =
			{ "", "", '"It\'s all talk until the code runs"', "", "                  — Ward Cunningham" }
	end,
	config = function()
		require("alpha").setup(require("alpha.themes.dashboard").config)
	end,
}
