local build = require("config.build")
local file = build.current_file()
local root = build.project_root({ "pyproject.toml", "requirements.txt", ".git" })

vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.keymap.set("n", "<leader>lb", function()
  build.open_terminal(build.shell_join({ "python3", file }), root)
end, { buffer = true, desc = "Run Python file" })
vim.keymap.set("n", "<leader>lt", function()
  build.open_terminal(build.shell_join({ "python3", "-m", "pytest", file }), root)
end, { buffer = true, desc = "Test Python file" })
