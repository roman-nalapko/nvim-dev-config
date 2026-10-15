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
local coding = require("plugins.coding")
local lsp = require("plugins.lsp")
local formatting = require("plugins.formatting")
local debugging = require("plugins.debug")
local git = require("plugins.git")
local languages = require("config.languages")
assert(plugin_exists(ui, "folke/tokyonight.nvim"), "Tokyo Night spec is missing")
assert(plugin_exists(ui, "folke/which-key.nvim"), "which-key spec is missing")
assert(plugin_exists(editor, "nvim-telescope/telescope.nvim"), "Telescope spec is missing")
assert(plugin_exists(editor, "nvim-tree/nvim-tree.lua"), "nvim-tree spec is missing")
assert(plugin_exists(treesitter, "nvim-treesitter/nvim-treesitter"), "Treesitter spec is missing")
assert(plugin_exists(coding, "saghen/blink.cmp"), "completion spec is missing")
assert(plugin_exists(lsp, "neovim/nvim-lspconfig"), "LSP spec is missing")
assert(plugin_exists(formatting, "stevearc/conform.nvim"), "formatter spec is missing")
assert(plugin_exists(debugging, "mfussenegger/nvim-dap"), "debugger spec is missing")
assert(plugin_exists(git, "lewis6991/gitsigns.nvim"), "Git signs spec is missing")

assert_equal("clangd", languages.lsp_servers[1], "primary C/C++ LSP")
assert_equal("basedpyright", languages.lsp_servers[2], "Python type-checking LSP")
assert_equal("ruff", languages.lsp_servers[3], "Python lint LSP")
assert_equal("pasls", languages.lsp_servers[4], "Pascal LSP")

local expected_build_maps = {
  c = "Build C target",
  cpp = "Build C++ target",
  python = "Run Python file",
  pascal = "Build Pascal file",
  asm = "Build assembly file",
}

for filetype, description in pairs(expected_build_maps) do
  vim.cmd("enew")
  vim.bo.filetype = filetype
  dofile(config_root .. "/after/ftplugin/" .. filetype .. ".lua")
  local mapping = vim.fn.maparg("<leader>lb", "n", false, true)
  assert_equal(description, mapping.desc, filetype .. " build mapping")
end

print("nvim smoke: ok")
