local languages = require("config.languages")

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
        },
      })
      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      })
      vim.lsp.config("pasls", {
        cmd = { "pasls" },
        filetypes = { "pascal" },
        root_markers = { "*.lpi", "*.lpr", "fpmake.pp", ".git" },
        workspace_required = false,
      })

      vim.lsp.enable(languages.lsp_servers)

      vim.diagnostic.config({
        severity_sort = true,
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 2, source = "if_many" },
        float = { border = "rounded", source = true },
        signs = {
          text = { "", "", "", "󰌵" },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("nvim_dev_lsp", { clear = true }),
        callback = function(event)
          local function lsp_map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
          end
          lsp_map("gd", vim.lsp.buf.definition, "Go to definition")
          lsp_map("gD", vim.lsp.buf.declaration, "Go to declaration")
          lsp_map("gr", vim.lsp.buf.references, "Find references")
          lsp_map("K", vim.lsp.buf.hover, "Hover documentation")
          lsp_map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          lsp_map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          lsp_map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          lsp_map("[d", function()
            vim.diagnostic.jump({ count = -1, float = true })
          end, "Previous diagnostic")
          lsp_map("]d", function()
            vim.diagnostic.jump({ count = 1, float = true })
          end, "Next diagnostic")
        end,
      })
    end,
  },
}
