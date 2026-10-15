local build = require("config.build")
local file = build.current_file()
local output = build.output_path()
local root = build.project_root({ "fpmake.pp", "*.lpi", ".git" })

vim.opt_local.expandtab = true
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.keymap.set("n", "<leader>lb", function()
  build.open_terminal(build.shell_join({ "fpc", "-g", "-gl", file }), root)
end, { buffer = true, desc = "Build Pascal file" })
vim.keymap.set("n", "<leader>lr", function()
  build.open_terminal(build.shell_join({ output }), root)
end, { buffer = true, desc = "Run Pascal target" })
