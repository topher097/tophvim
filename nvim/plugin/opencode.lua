if vim.g.did_load_opencode_plugin then
  return
end
vim.g.did_load_opencode_plugin = true

-- Required by opencode.nvim when events.reload is enabled (default).
vim.o.autoread = true

---@type opencode.Opts
vim.g.opencode_opts = {}

local opencode = require('opencode')

vim.keymap.set({ 'n', 'x' }, '<leader>oa', function()
  opencode.ask('@this: ', { submit = true })
end, { desc = '[o]pencode [a]sk' })

vim.keymap.set({ 'n', 'x' }, '<leader>or', function()
  return opencode.operator('@this ')
end, { desc = '[o]pencode add [r]ange', expr = true })

vim.keymap.set('n', '<leader>oR', function()
  return opencode.operator('@this ') .. '_'
end, { desc = '[o]pencode add cu[R]rent line', expr = true })

vim.keymap.set('n', '<leader>oo', function()
  opencode.select()
end, { desc = '[o]pencode select acti[o]n' })

vim.keymap.set({ 'n', 't' }, '<leader>ot', function()
  opencode.toggle()
end, { desc = '[o]pencode [t]oggle' })

vim.keymap.set('n', '<leader>ok', function()
  opencode.command('session.half.page.up')
end, { desc = '[o]pencode scroll up' })

vim.keymap.set('n', '<leader>oj', function()
  opencode.command('session.half.page.down')
end, { desc = '[o]pencode scroll down' })
