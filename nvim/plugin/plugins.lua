if vim.g.did_load_plugins_plugin then
  return
end
vim.g.did_load_plugins_plugin = true

vim.o.termguicolors = true

require('rose-pine').setup {
  variant = 'auto',
  dark_variant = 'main',
}

vim.cmd.colorscheme('rose-pine')
