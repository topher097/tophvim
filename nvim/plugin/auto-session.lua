if vim.g.did_load_auto_session_plugin then
  return
end
vim.g.did_load_auto_session_plugin = true

require('auto-session').setup {
  auto_restore = false,
  bypass_save_filetypes = { 'alpha' },
}
