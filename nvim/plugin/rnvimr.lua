if vim.g.did_load_rnvimr_plugin then
  return
end
vim.g.did_load_rnvimr_plugin = true

-- Make Ranger replace Netrw and be the file explorer
vim.g.rnvimr_enable_ex = 1

-- Make Ranger to be hidden after picking a file
vim.g.rnvimr_enable_picker = 1

-- Replace `$EDITOR` candidate with this command to open the selected file
vim.g.rnvimr_edit_cmd = 'drop'

-- Disable a border for floating window
vim.g.rnvimr_draw_border = 0

-- Hide the files included in gitignore
vim.g.rnvimr_hide_gitignore = 1

-- Change the border's color
vim.g.rnvimr_border_attr = { fg = 14, bg = -1 }

-- Make Neovim wipe the buffers corresponding to the files deleted by Ranger
vim.g.rnvimr_enable_bw = 1

-- Add a shadow window, value is equal to 100 will disable shadow
vim.g.rnvimr_shadow_winblend = 70

-- Draw border with both, ensure previews are enabled
vim.g.rnvimr_ranger_cmd = {
  'ranger',
  '--cmd=set draw_borders both',
  '--cmd=set preview_files true',
  '--cmd=set use_preview_script true',
}

-- Link CursorLine into RnvimrNormal highlight in the Floating window
vim.api.nvim_set_hl(0, 'RnvimrNormal', { link = 'CursorLine' })

-- Map Rnvimr action
vim.g.rnvimr_action = {
  ['<C-t>'] = 'NvimEdit tabedit',
  ['<C-x>'] = 'NvimEdit split',
  ['<C-v>'] = 'NvimEdit vsplit',
  ['gw'] = 'JumpNvimCwd',
  ['yw'] = 'EmitRangerCwd',
}

-- Add views for Ranger to adapt the size of floating window
vim.g.rnvimr_ranger_views = {
  { minwidth = 90, ratio = {} },
  { minwidth = 50, maxwidth = 89, ratio = { 1, 1 } },
  { maxwidth = 49, ratio = { 1 } },
}

-- Customize the initial layout
vim.g.rnvimr_layout = {
  relative = 'editor',
  width = math.floor(0.7 * vim.o.columns),
  height = math.floor(0.7 * vim.o.lines),
  col = math.floor(0.15 * vim.o.columns),
  row = math.floor(0.15 * vim.o.lines),
  style = 'minimal',
}

-- Customize multiple preset layouts
-- '{}' represents the initial layout
vim.g.rnvimr_presets = {
  { width = 0.600, height = 0.600 },
  vim.empty_dict(),
  { width = 0.800, height = 0.800 },
  { width = 0.950, height = 0.950 },
  { width = 0.500, height = 0.500, col = 0, row = 0 },
  { width = 0.500, height = 0.500, col = 0, row = 0.5 },
  { width = 0.500, height = 0.500, col = 0.5, row = 0 },
  { width = 0.500, height = 0.500, col = 0.5, row = 0.5 },
  { width = 0.500, height = 1.000, col = 0, row = 0 },
  { width = 0.500, height = 1.000, col = 0.5, row = 0 },
  { width = 1.000, height = 0.500, col = 0, row = 0 },
  { width = 1.000, height = 0.500, col = 0, row = 0.5 },
}

-- Keymaps
vim.keymap.set('n', '<M-o>', '<cmd>RnvimrToggle<cr>', { silent = true, desc = 'rnvimr toggle' })
vim.keymap.set('t', '<M-o>', '<C-\\><C-n><cmd>RnvimrToggle<cr>', { silent = true, desc = 'rnvimr toggle' })
vim.keymap.set('t', '<M-i>', '<C-\\><C-n><cmd>RnvimrResize<cr>', { silent = true, desc = 'rnvimr resize' })
vim.keymap.set('t', '<M-l>', '<C-\\><C-n><cmd>RnvimrResize 1,8,9,11,5<cr>', { silent = true, desc = 'rnvimr resize preset' })
vim.keymap.set('t', '<M-y>', '<C-\\><C-n><cmd>RnvimrResize 6<cr>', { silent = true, desc = 'rnvimr resize single' })
