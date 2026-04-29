if vim.g.did_load_smart_splits_plugin then
  return
end
vim.g.did_load_smart_splits_plugin = true

local smart_splits = require('smart-splits')

smart_splits.setup {
  multiplexer_integration = 'zellij',
  zellij_move_focus_or_tab = true,
}

vim.keymap.set('n', '<A-h>', function()
  smart_splits.resize_left()
end, { desc = 'smart-splits: resize left' })
vim.keymap.set('n', '<A-j>', function()
  smart_splits.resize_down()
end, { desc = 'smart-splits: resize down' })
vim.keymap.set('n', '<A-k>', function()
  smart_splits.resize_up()
end, { desc = 'smart-splits: resize up' })
vim.keymap.set('n', '<A-l>', function()
  smart_splits.resize_right()
end, { desc = 'smart-splits: resize right' })

vim.keymap.set('n', '<C-h>', function()
  smart_splits.move_cursor_left()
end, { desc = 'smart-splits: move left' })
vim.keymap.set('n', '<C-j>', function()
  smart_splits.move_cursor_down()
end, { desc = 'smart-splits: move down' })
vim.keymap.set('n', '<C-k>', function()
  smart_splits.move_cursor_up()
end, { desc = 'smart-splits: move up' })
vim.keymap.set('n', '<C-l>', function()
  smart_splits.move_cursor_right()
end, { desc = 'smart-splits: move right' })
vim.keymap.set('n', '<C-\\>', function()
  smart_splits.move_cursor_previous()
end, { desc = 'smart-splits: move to previous pane' })

vim.keymap.set('n', '<leader><leader>h', function()
  smart_splits.swap_buf_left()
end, { desc = 'smart-splits: swap buffer left' })
vim.keymap.set('n', '<leader><leader>j', function()
  smart_splits.swap_buf_down()
end, { desc = 'smart-splits: swap buffer down' })
vim.keymap.set('n', '<leader><leader>k', function()
  smart_splits.swap_buf_up()
end, { desc = 'smart-splits: swap buffer up' })
vim.keymap.set('n', '<leader><leader>l', function()
  smart_splits.swap_buf_right()
end, { desc = 'smart-splits: swap buffer right' })
