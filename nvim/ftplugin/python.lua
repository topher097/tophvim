-- Start Python language servers when available.

local lsp = require('user.lsp')

local root_files = {
  'ty.toml',
  'pyproject.toml',
  'setup.py',
  'setup.cfg',
  'requirements.txt',
  'ruff.toml',
  '.ruff.toml',
  '.git',
}

local root_match = vim.fs.find(root_files, { upward = true })[1]
local root_dir = root_match and vim.fs.dirname(root_match) or vim.fn.getcwd()

if vim.fn.executable('ty') == 1 then
  vim.lsp.start {
    name = 'ty',
    cmd = { 'ty', 'server' },
    root_dir = root_dir,
    capabilities = lsp.make_client_capabilities(),
  }
end

if vim.fn.executable('ruff') == 1 then
  vim.lsp.start {
    name = 'ruff',
    cmd = { 'ruff', 'server' },
    root_dir = root_dir,
    capabilities = lsp.make_client_capabilities(),
  }
end
