return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts = {
		delay = 0,
		icons = {
			mappings = false,
			keys = {
				Up = "<Up> ",
				Down = "<Down> ",
				Left = "<Left> ",
				Right = "<Right> ",
				C = "<C-…> ",
				M = "<M-…> ",
				D = "<D-…> ",
				S = "<S-…> ",
				CR = "<CR> ",
				Esc = "<Esc> ",
				Space = "<Space> ",
				Tab = "<Tab> ",
			},
		},
		spec = {
			{ "<leader>s", group = "[s]earch" },
			{ "<leader>t", group = "[t]oggle" },
		},
	},
}
