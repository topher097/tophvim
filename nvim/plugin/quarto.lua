if vim.g.did_load_quarto_plugin then
  return
end
vim.g.did_load_quarto_plugin = true

require('quarto').setup {
  lspFeatures = {
    enabled = true,
    chunks = 'all',
    languages = { 'python', 'bash', 'lua', 'r' },
    diagnostics = {
      enabled = true,
      triggers = { 'BufWritePost' },
    },
    completion = {
      enabled = true,
    },
  },
  codeRunner = {
    enabled = true,
    default_method = 'molten',
  },
}

local runner = require('quarto.runner')
vim.keymap.set('n', '<leader>jc', runner.run_cell, { desc = '[j]upyter run [c]ell', silent = true })
vim.keymap.set('n', '<leader>ja', runner.run_above, { desc = '[j]upyter run [a]bove', silent = true })
vim.keymap.set('n', '<leader>jA', runner.run_all, { desc = '[j]upyter run [A]ll', silent = true })
vim.keymap.set('n', '<leader>jL', runner.run_line, { desc = '[j]upyter run [L]ine (quarto)', silent = true })
vim.keymap.set('v', '<leader>jq', runner.run_range, { desc = '[j]upyter run visual range (quarto)', silent = true })
