return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        prompt_prefix = "   ",
        selection_caret = "  ",
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
        border = true,
      },
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      sync_root_with_cwd = true,
      update_focused_file = { enable = true, update_root = false },
      view = { width = 34, side = "left" },
      renderer = { group_empty = true, highlight_git = true, root_folder_label = false },
      filters = { custom = { "^.git$" } },
    },
  },
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "kylechui/nvim-surround", event = "VeryLazy", version = "*", opts = {} },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "ToggleTerm",
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", desc = "Floating terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
    },
    opts = {
      size = 15,
      open_mapping = [[<c-\>]],
      shade_terminals = false,
      direction = "float",
      float_opts = { border = "rounded" },
    },
  },
}
