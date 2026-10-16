local M = {}

M.parsers = {
  "asm",
  "bash",
  "c",
  "cmake",
  "cpp",
  "json",
  "lua",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "vim",
  "vimdoc",
  "yaml",
}

function M.install()
  return require("nvim-treesitter").install(M.parsers)
end

function M.update()
  return require("nvim-treesitter").update(M.parsers)
end

return M
