local M = {}

local function shell_join(parts)
  return table.concat(vim.tbl_map(vim.fn.shellescape, parts), " ")
end

function M.current_file()
  return vim.fn.expand("%:p")
end

function M.output_path()
  return vim.fn.expand("%:p:r")
end

function M.shell_join(parts)
  return shell_join(parts)
end

function M.choose_executable(default)
  return vim.fn.input("Executable: ", default, "file")
end

function M.open_terminal(command, cwd)
  vim.cmd("botright 12split | enew")
  vim.bo.bufhidden = "wipe"
  local job = vim.fn.jobstart({ "sh", "-lc", command }, {
    cwd = cwd or vim.fn.getcwd(),
    term = true,
  })
  if job <= 0 then
    vim.notify("Failed to start build command", vim.log.levels.ERROR)
    return
  end
  vim.cmd("startinsert")
end

function M.project_root(markers)
  return vim.fs.root(0, markers) or vim.fn.getcwd()
end

return M
