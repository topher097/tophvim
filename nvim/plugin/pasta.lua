local pasta = require('pasta')

pasta.config.next_key = vim.keycode('<C-n>')
pasta.config.prev_key = vim.keycode('<C-p>')
pasta.config.indent_fix = true

vim.keymap.set({ 'n', 'x' }, 'p', function()
  pasta.start(true)
end, { silent = true })
vim.keymap.set({ 'n', 'x' }, 'P', function()
  pasta.start(false)
end, { silent = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    pasta.add_entry(vim.v.event.regcontents and {
      regtype = vim.v.event.regtype,
      regcontents = vim.v.event.regcontents,
    } or vim.fn.getreginfo(vim.v.register))
  end,
})
