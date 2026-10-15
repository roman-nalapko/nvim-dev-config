local build = require("config.build")
local file = build.current_file()
local output = build.output_path()
local root = build.project_root({ "CMakeLists.txt", "Makefile", ".git" })
local command
local run_default

if vim.uv.fs_stat(root .. "/CMakeLists.txt") then
  command = build.shell_join({ "cmake", "-S", root, "-B", root .. "/build", "-DCMAKE_BUILD_TYPE=Debug" })
    .. " && "
    .. build.shell_join({ "cmake", "--build", root .. "/build" })
  run_default = root .. "/build/"
elseif vim.uv.fs_stat(root .. "/Makefile") then
  command = build.shell_join({ "make", "-C", root })
  run_default = root .. "/"
else
  command = build.shell_join({ "clang", "-std=c17", "-Wall", "-Wextra", "-g", file, "-o", output })
end

vim.keymap.set("n", "<leader>lb", function()
  build.open_terminal(command, root)
end, { buffer = true, desc = "Build C target" })
vim.keymap.set("n", "<leader>lr", function()
  local executable = run_default and build.choose_executable(run_default) or output
  if executable ~= "" then
    build.open_terminal(build.shell_join({ executable }), root)
  end
end, { buffer = true, desc = "Run C target" })
