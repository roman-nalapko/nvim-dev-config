return {
  lsp_servers = { "clangd", "basedpyright", "ruff", "pasls" },
  formatters = {
    c = { "clang_format" },
    cpp = { "clang_format" },
    python = { "ruff_format" },
    lua = { "stylua" },
  },
}
