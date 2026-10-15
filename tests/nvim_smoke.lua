local repo = vim.fn.getcwd()
local config_root = repo .. "/nvim"

vim.opt.runtimepath:prepend(config_root)
package.path = table.concat({
  config_root .. "/lua/?.lua",
  config_root .. "/lua/?/init.lua",
  package.path,
}, ";")
vim.g.nvim_dev_config_test = true

local function assert_equal(expected, actual, message)
  if expected ~= actual then
    error(string.format("%s: expected %s, got %s", message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function plugin_exists(specs, name)
  for _, spec in ipairs(specs) do
    if spec[1] == name then
      return true
    end
  end
  return false
end

dofile(config_root .. "/init.lua")

assert_equal(" ", vim.g.mapleader, "leader")
assert_equal("\\", vim.g.maplocalleader, "local leader")
assert_equal(true, vim.o.number, "line numbers")
assert_equal(true, vim.o.relativenumber, "relative line numbers")
assert_equal(true, vim.o.termguicolors, "true color")
assert_equal("yes", vim.o.signcolumn, "sign column")

local find_files = vim.fn.maparg("<leader>ff", "n", false, true)
assert_equal("Find files", find_files.desc, "file finder mapping")
local explorer = vim.fn.maparg("<leader>e", "n", false, true)
assert_equal("File explorer", explorer.desc, "file explorer mapping")
local terminal_escape = vim.fn.maparg("<Esc><Esc>", "t", false, true)
assert_equal("Leave terminal mode", terminal_escape.desc, "terminal escape mapping")

vim.api.nvim_exec_autocmds("ColorScheme", {})
local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
assert_equal(nil, normal.bg, "transparent Normal background")

local ui = require("plugins.ui")
local editor = require("plugins.editor")
local treesitter = require("plugins.treesitter")
assert(plugin_exists(ui, "folke/tokyonight.nvim"), "Tokyo Night spec is missing")
assert(plugin_exists(ui, "folke/which-key.nvim"), "which-key spec is missing")
assert(plugin_exists(editor, "nvim-telescope/telescope.nvim"), "Telescope spec is missing")
assert(plugin_exists(editor, "nvim-tree/nvim-tree.lua"), "nvim-tree spec is missing")
assert(plugin_exists(treesitter, "nvim-treesitter/nvim-treesitter"), "Treesitter spec is missing")

print("nvim smoke: ok")
