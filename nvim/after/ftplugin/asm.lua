local build = require("config.build")
local file = build.current_file()
local output = build.output_path()
local root = build.project_root({ "Makefile", ".git" })
local command

if vim.uv.os_uname().sysname == "Darwin" then
  command = build.shell_join({ "clang", "-g", file, "-o", output })
else
  local object = output .. ".o"
  command = build.shell_join({ "nasm", "-f", "elf64", "-g", "-F", "dwarf", file, "-o", object })
    .. " && " .. build.shell_join({ "cc", "-g", "-no-pie", object, "-o", output })
end

vim.keymap.set("n", "<leader>lb", function() build.open_terminal(command, root) end, { buffer = true, desc = "Build assembly file" })
vim.keymap.set("n", "<leader>lr", function() build.open_terminal(build.shell_join({ output }), root) end, { buffer = true, desc = "Run assembly target" })
