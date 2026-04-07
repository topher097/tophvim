if vim.g.did_load_markdown_plus_plugin then
  return
end
vim.g.did_load_markdown_plus_plugin = true

require('markdown-plus').setup {
  keymaps = {
    enabled = true,
  },
}
