if vim.g.did_load_fm_nvim_plugin then
  return
end
vim.g.did_load_fm_nvim_plugin = true

require('fm-nvim').setup {
  edit_cmd = 'edit',
  ui = {
    default = 'float',
    float = {
      border = 'rounded',
      float_hl = 'Normal',
      border_hl = 'FloatBorder',
      blend = 0,
      height = 0.85,
      width = 0.85,
      x = 0.5,
      y = 0.5,
    },
  },
  -- Use system xplr (not packaged in Nix) so user config is respected
  cmds = {
    xplr_cmd = 'xplr',
  },
}

vim.keymap.set('n', '<leader>x', '<cmd>Xplr<cr>', { desc = '[x]plr file manager' })
vim.keymap.set('n', '<leader>xd', function()
  vim.cmd('Xplr ' .. vim.fn.expand('%:p:h'))
end, { desc = '[x]plr in current [d]irectory' })
