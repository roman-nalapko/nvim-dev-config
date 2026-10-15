if vim.fn.has("nvim-0.12") ~= 1 then
  error("nvim-dev-config requires Neovim 0.12 or newer")
end

require("config.options")
require("config.keymaps")
require("config.autocmds")

if not vim.g.nvim_dev_config_test then
  require("config.lazy")
end
