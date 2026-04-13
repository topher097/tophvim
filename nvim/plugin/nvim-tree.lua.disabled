-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- empty setup using defaults
require('nvim-tree').setup()

-- Toggle tree
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle file [e]xplorer' })
vim.keymap.set('n', '<leader>ef', '<cmd>NvimTreeFocus<cr>', { desc = 'Focus file [e]xplorer' })
vim.keymap.set('n', '<leader>el', '<cmd>NvimTreeFindFile<cr>', { desc = 'Find current file in [e]xplorer' })

-- OR setup with a config

---@type nvim_tree.config
local config = {
  sort = {
    sorter = 'case_sensitive',
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
  actions = {
    open_file = {
      quit_on_open = false,
    },
  },
}
require('nvim-tree').setup(config)

-- Allow :wq to properly close when nvim-tree is open
vim.api.nvim_create_autocmd('QuitPre', {
  callback = function()
    local tree_wins = {}
    local floating_wins = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        table.insert(floating_wins, win)
      else
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'NvimTree' then
          table.insert(tree_wins, win)
        end
      end
    end
    for _, win in ipairs(floating_wins) do
      vim.api.nvim_win_close(win, true)
    end
    if 1 == #tree_wins + #floating_wins then
      -- Close all windows except last
      for _, win in ipairs(tree_wins) do
        vim.api.nvim_win_close(win, true)
      end
    end
  end,
})
