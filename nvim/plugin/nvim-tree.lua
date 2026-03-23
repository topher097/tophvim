  -- disable netrw at the very start of your init.lua
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  -- optionally enable 24-bit colour
  vim.opt.termguicolors = true

  -- empty setup using defaults
  require("nvim-tree").setup()

  -- Open tree automatically when a file is opened
  vim.api.nvim_create_autocmd("BufReadPost", {
    once = true,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and vim.bo[buf].buftype == "" then
        require("nvim-tree.api").tree.open({ focus = false })
      end
    end,
  })

  -- Toggle tree
  vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file [e]xplorer" })
  vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFocus<cr>", { desc = "Focus file [e]xplorer" })
  vim.keymap.set("n", "<leader>el", "<cmd>NvimTreeFindFile<cr>", { desc = "Find current file in [e]xplorer" })

  -- OR setup with a config

  ---@type nvim_tree.config
  local config = {
    sort = {
      sorter = "case_sensitive",
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
  }
  require("nvim-tree").setup(config)