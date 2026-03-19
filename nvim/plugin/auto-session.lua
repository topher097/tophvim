if vim.g.did_load_auto_session_plugin then
  return
end
vim.g.did_load_auto_session_plugin = true

require('auto-session').setup {
  bypass_save_filetypes = { 'alpha' },
}
