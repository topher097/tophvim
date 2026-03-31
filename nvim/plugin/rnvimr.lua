if vim.g.did_load_rnvimr_plugin then
  return
end
vim.g.did_load_rnvimr_plugin = true

local map = vim.keymap.set

-- Toggle Ranger (normal mode)
map('n', '<M-o>', '<cmd>RnvimrToggle<cr>', { silent = true, desc = 'Toggle Ranger' })

-- Toggle Ranger (terminal mode)
map('t', '<M-o>', '<C-\\><C-n><cmd>RnvimrToggle<cr>', { silent = true, desc = 'Toggle Ranger' })

-- Resize floating window (terminal mode)
map('t', '<M-i>', '<C-\\><C-n><cmd>RnvimrResize<cr>', { silent = true, desc = 'Resize Ranger' })

-- Exit ranger/floating window (terminal mode)
map('t', '<C-q>', '<C-\\><C-n>', { silent = true, desc = 'Exit terminal' })
