local build = require("config.build")
local file = build.current_file()
local output = build.output_path()
local root = build.project_root({ "CMakeLists.txt", "Makefile", ".git" })
local command

if vim.uv.fs_stat(root .. "/CMakeLists.txt") then
  command = build.shell_join({ "cmake", "-S", root, "-B", root .. "/build", "-DCMAKE_BUILD_TYPE=Debug" })
    .. " && "
    .. build.shell_join({ "cmake", "--build", root .. "/build" })
elseif vim.uv.fs_stat(root .. "/Makefile") then
  command = build.shell_join({ "make", "-C", root })
else
  command = build.shell_join({ "clang", "-std=c17", "-Wall", "-Wextra", "-g", file, "-o", output })
end

vim.keymap.set("n", "<leader>lb", function()
  build.open_terminal(command, root)
end, { buffer = true, desc = "Build C target" })
vim.keymap.set("n", "<leader>lr", function()
  build.open_terminal(build.shell_join({ output }), root)
end, { buffer = true, desc = "Run C target" })
