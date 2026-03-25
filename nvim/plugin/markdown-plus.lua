if vim.g.did_load_markdown_plus_plugin then
  return
end
vim.g.did_load_markdown_plus_plugin = true

-- Use default keymaps with custom prefix
-- Change this to customize the keybindings prefix
vim.g.maplocalleader = ' '

require('markdown-plus').setup {
  keymaps = {
    enabled = true,
  },
}
