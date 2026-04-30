local wk = require('which-key')
wk.setup {
  preset = 'helix',
}

wk.add {
  { ';', group = 'tide' },
  { ';;', desc = 'open panel' },
  { ';a', desc = 'add item' },
  { ';d', desc = 'delete item' },
  { ';x', desc = 'clear all' },
  { ';-', desc = 'horizontal split' },
  { ';|', desc = 'vertical split' },
  { 'g', group = 'goto' },
}
