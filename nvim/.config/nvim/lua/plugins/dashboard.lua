return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
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

		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", "<cmd>ene<CR>"),
			dashboard.button("f", "󰱼  [f]ind files", "<cmd>Telescope find_files<CR>"),
			dashboard.button("g", "󰱼  search by [g]rep", "<cmd>Telescope live_grep<CR>"),
			dashboard.button("p", "󰐱  manage [p]lugins", "<cmd>Lazy<CR>"),
			dashboard.button("q", "󰗼  [q]uit", "<cmd>qa<CR>"),
		}

		dashboard.section.footer.val =
			{ "", "", '"It\'s all talk until the code runs"', "", "                  — Ward Cunningham" }

		require("alpha").setup(dashboard.config)
	end,
}
