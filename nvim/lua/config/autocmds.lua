local group = vim.api.nvim_create_augroup("nvim_dev_config", { clear = true })

local transparent_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "SignColumn",
  "EndOfBuffer",
  "NvimTreeNormal",
  "NvimTreeNormalNC",
  "TelescopeNormal",
  "TelescopeBorder",
}

local function apply_transparency()
  for _, name in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, name, { bg = "none" })
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = apply_transparency,
})
apply_transparency()

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Highlight copied text",
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  desc = "Create missing parent directories",
  callback = function(event)
    local file = vim.uv.fs_realpath(event.match) or event.match
    local parent = vim.fs.dirname(file)
    if parent and vim.fn.isdirectory(parent) == 0 then
      vim.fn.mkdir(parent, "p")
    end
  end,
})
