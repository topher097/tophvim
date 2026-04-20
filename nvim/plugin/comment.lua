if vim.g.did_load_comment_plugin then
  return
end
vim.g.did_load_comment_plugin = true

require('Comment').setup {
  toggler = {
    line = '<C-/>',
    block = 'gbc',
  },
  opleader = {
    line = 'gc',
    block = 'gb',
  },
}

vim.keymap.set('x', '<C-/>', 'gc', { remap = true, desc = 'toggle comment (visual)' })
