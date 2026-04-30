if vim.g.did_load_toggleterm_plugin then
  return
end
vim.g.did_load_toggleterm_plugin = true

require('toggleterm').setup {
  size = function(term)
    if term.direction == 'horizontal' then
      return 15
    elseif term.direction == 'vertical' then
      return vim.o.columns * 0.4
    end
  end,
  open_mapping = '<leader>bt',
  direction = 'horizontal',
}

vim.keymap.set('n', '<leader>bh', '<cmd>ToggleTerm direction=horizontal<cr>', { desc = '[b] terminal [h]orizontal term' })
vim.keymap.set('n', '<leader>bv', '<cmd>ToggleTerm direction=vertical<cr>', { desc = '[b] terminal [v]ertical term' })
vim.keymap.set('n', '<leader>bf', '<cmd>ToggleTerm direction=float<cr>', { desc = '[b] terminal [f]loat term' })
