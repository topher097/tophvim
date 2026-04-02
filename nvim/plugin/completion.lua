if vim.g.did_load_completion_plugin then
  return
end
vim.g.did_load_completion_plugin = true

local blink_cmp = require('blink.cmp')

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

blink_cmp.setup {
  -- Keep blink defaults, while matching VSCode-style completion keys.
  keymap = {
    preset = 'super-tab',
    ['<CR>'] = { 'select_and_accept', 'fallback' },
  },
}
