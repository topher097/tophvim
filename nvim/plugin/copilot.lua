if vim.g.did_load_copilot_plugin then
  return
end
vim.g.did_load_copilot_plugin = true

require('copilot').setup {}
