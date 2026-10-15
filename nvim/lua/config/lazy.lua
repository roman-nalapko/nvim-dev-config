local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local result = vim
    .system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=stable",
      "https://github.com/folke/lazy.nvim.git",
      lazypath,
    }, { text = true })
    :wait(120000)

  if result.code ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. (result.stderr or result.stdout or "unknown error"))
  end
end

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  defaults = { lazy = true, version = false },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  rocks = { enabled = false },
  ui = { border = "rounded" },
})
