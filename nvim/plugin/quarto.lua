if vim.g.did_load_quarto_plugin then
  return
end
vim.g.did_load_quarto_plugin = true

-- Compatibility for older otter.nvim builds (seen in some nixpkgs snapshots):
-- `quarto.runner` may require `otter.keeper` before otter's plugin file has
-- loaded `otter.config`, leaving global `OtterConfig` nil.
pcall(require, 'otter.config')

local function to_python_single_quoted_string(text)
  return "'"
    .. text:gsub('\\', '\\\\'):gsub('\r', '\\r'):gsub('\n', '\\n'):gsub("'", "\\'")
    .. "'"
end

local function molten_namespace()
  return vim.api.nvim_get_namespaces()['molten-extmarks']
end

local function plain_molten_extmarks(bufnr, ns)
  local marks = {}
  if ns == nil then
    return marks
  end

  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })) do
    local id = mark[1]
    local row = mark[2]
    local col = mark[3]
    local details = mark[4] or {}

    if details.virt_text == nil and details.virt_lines == nil then
      marks[id] = {
        row = row,
        col = col,
        right_gravity = details.right_gravity == true,
      }
    end
  end

  return marks
end

local function run_bash_cell(cell)
  local lines = cell.text or {}
  if #lines == 0 then
    return
  end
  -- Run bash through the project's direnv env when available.
  local use_direnv = vim.fn.executable('direnv') == 1
    and vim.uv.fs_stat(vim.fn.getcwd() .. '/.envrc') ~= nil

  local bash_lines = {}
  if use_direnv then
    table.insert(bash_lines, 'eval "$(direnv export bash 2>/dev/null)"')
  end
  vim.list_extend(bash_lines, lines)

  local range = cell.range
  local start_line = range and range.from and range.from[1] or nil
  local end_line = range and range.to and range.to[1] or nil

  -- MoltenEvaluateArgument anchors output to a zero-length cell at (0,0),
  -- which can make output appear under the next executed cell. EvaluateRange
  -- anchors output to the actual code cell range, so we temporarily swap the
  -- bash cell with Python that runs the full bash script, evaluate that exact
  -- range, then restore the original text.
  if type(start_line) == 'number' and type(end_line) == 'number' then
    local bufnr = vim.api.nvim_get_current_buf()
    local original_lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
    local ns = molten_namespace()
    local marks_before = plain_molten_extmarks(bufnr, ns)
    local script = table.concat(bash_lines, '\n')
    local python_payload = (
      "import subprocess; subprocess.run(['/usr/bin/env', 'bash', '-lc', %s], check=False)"
    ):format(to_python_single_quoted_string(script))
    local payload_lines = { python_payload }
    for _ = 2, #original_lines do
      table.insert(payload_lines, '')
    end

    local ok_replace, replace_err = pcall(vim.api.nvim_buf_set_lines, bufnr, start_line, end_line, false, payload_lines)
    if not ok_replace then
      error(replace_err)
    end

    local ok_eval, eval_err = pcall(vim.fn.MoltenEvaluateRange, start_line + 1, end_line)
    local marks_after_eval = plain_molten_extmarks(bufnr, ns)
    local new_mark_positions = {}
    for id, pos in pairs(marks_after_eval) do
      if marks_before[id] == nil then
        new_mark_positions[id] = pos
      end
    end

    local ok_restore, restore_err = pcall(vim.api.nvim_buf_set_lines, bufnr, start_line, end_line, false, original_lines)

    if not ok_restore then
      vim.notify(('Quarto bash runner failed to restore cell text: %s'):format(tostring(restore_err)), vim.log.levels.ERROR)
    end

    if ns ~= nil and ok_restore then
      for id, pos in pairs(new_mark_positions) do
        pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, pos.row, pos.col, {
          id = id,
          right_gravity = pos.right_gravity,
          strict = false,
        })
      end
    end

    if not ok_eval then
      error(eval_err)
    end

    return
  end

  -- Fallback path when range/kernel info is unavailable.
  local code_lines = { '%%bash' }
  vim.list_extend(code_lines, bash_lines)
  local code = table.concat(code_lines, '\n')
  vim.api.nvim_cmd({ cmd = 'MoltenEvaluateArgument', args = { code } }, {})
end

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
    ft_runners = {
      bash = run_bash_cell,
    },
  },
}

local runner = require('quarto.runner')
vim.keymap.set('n', '<leader>jc', runner.run_cell, { desc = '[j]upyter run [c]ell', silent = true })
vim.keymap.set('n', '<leader>ja', runner.run_above, { desc = '[j]upyter run [a]bove', silent = true })
vim.keymap.set('n', '<leader>jA', runner.run_all, { desc = '[j]upyter run [A]ll', silent = true })
vim.keymap.set('n', '<leader>jL', runner.run_line, { desc = '[j]upyter run [L]ine (quarto)', silent = true })
vim.keymap.set('v', '<leader>jq', runner.run_range, { desc = '[j]upyter run visual range (quarto)', silent = true })
