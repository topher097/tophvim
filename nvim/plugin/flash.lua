if vim.g.did_load_flash_plugin then
  return
end
vim.g.did_load_flash_plugin = true

local flash = require('flash')

flash.setup {}

vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
  flash.jump()
end, { desc = 'flash jump' })

vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
  flash.treesitter()
end, { desc = 'flash treesitter' })

vim.keymap.set('o', 'r', function()
  flash.remote()
end, { desc = 'flash remote' })

vim.keymap.set({ 'o', 'x' }, 'R', function()
  flash.treesitter_search()
end, { desc = 'flash treesitter search' })

vim.keymap.set('c', '<C-s>', function()
  flash.toggle()
end, { desc = 'toggle flash search' })
