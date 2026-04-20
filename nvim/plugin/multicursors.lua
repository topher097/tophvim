if vim.g.did_load_multicursors_plugin then
  return
end
vim.g.did_load_multicursors_plugin = true

require('multicursors').setup()

vim.keymap.set('n', '<Leader>c', '<cmd>MCstart<cr>', { desc = 'multicursor: start from word' })
vim.keymap.set('v', '<Leader>c', '<cmd>MCvisual<cr>', { desc = 'multicursor: start from selection' })
