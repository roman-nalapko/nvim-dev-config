return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function git_map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end
        git_map("]h", function() gs.nav_hunk("next") end, "Next Git hunk")
        git_map("[h", function() gs.nav_hunk("prev") end, "Previous Git hunk")
        git_map("<leader>gp", gs.preview_hunk, "Preview hunk")
        git_map("<leader>gs", gs.stage_hunk, "Stage hunk")
        git_map("<leader>gr", gs.reset_hunk, "Reset hunk")
        git_map("<leader>gb", gs.blame_line, "Blame line")
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gdiffsplit", "Gread", "Gwrite" },
    keys = { { "<leader>gg", "<cmd>Git<CR>", desc = "Git status" } },
  },
}
