if vim.g.did_load_multicursors_plugin then
  return
end
vim.g.did_load_multicursors_plugin = true

local ok, multicursors = pcall(require, 'multicursors')
if not ok then
  return
end

local default_config = require('multicursors.config')
local highlight = require('multicursors.highlight')
local layers = require('multicursors.layers')

-- Work around smoka7/multicursors.nvim#104: the plugin's setup() calls
-- vim.tbl_deep_extend('keep', opts, default_config) which crashes on
-- Neovim >= 0.11 because default_config contains mixed-key sub-tables
-- (e.g. generate_hints.config) that violate the new type-checking rules
-- in tbl_deep_extend.  Manually merge and call the setup steps directly.
local function merge_defaults(user_opts)
  local config = {}
  for k, v in pairs(default_config) do
    if user_opts[k] ~= nil then
      if type(v) == 'table' and type(user_opts[k]) == 'table' then
        local merged = {}
        for dk, dv in pairs(v) do
          merged[dk] = dv
        end
        for uk, uv in pairs(user_opts[k]) do
          merged[uk] = uv
        end
        config[k] = merged
      else
        config[k] = user_opts[k]
      end
    else
      config[k] = v
    end
  end
  return config
end

local config = merge_defaults {}

vim.g.MultiCursorDebug = config.DEBUG_MODE

highlight.set_highlights()

vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  callback = function()
    highlight.set_highlights()
  end,
})

if config.create_commands then
  vim.api.nvim_create_user_command('MCstart', function()
    multicursors.start()
  end, {})
  vim.api.nvim_create_user_command('MCvisual', function()
    multicursors.search_visual()
  end, { range = 0 })
  vim.api.nvim_create_user_command('MCunderCursor', function()
    multicursors.new_under_cursor()
  end, {})
  vim.api.nvim_create_user_command('MCclear', function()
    multicursors.exit()
  end, {})
  vim.api.nvim_create_user_command('MCpattern', function()
    multicursors.new_pattern()
  end, {})
  vim.api.nvim_create_user_command('MCvisualPattern', function()
    multicursors.new_pattern_visual()
  end, { range = 0 })
  vim.keymap.set('n', '<leader>c', '<cmd>MCstart<cr>', { desc = 'multicursor: start from word' })
  vim.keymap.set('v', '<leader>c', '<cmd>MCvisual<cr>', { desc = 'multicursor: start from selection' })
end

layers.create_normal_hydra(config)
