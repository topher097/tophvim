if vim.g.did_load_markdown_plus_plugin then
  return
end
vim.g.did_load_markdown_plus_plugin = true

require('markdown-plus').setup {
  keymaps = {
    enabled = true,
  },
}

vim.keymap.set('v', '<leader>ms', function()
  local v_pos = vim.fn.getpos('v')
  local dot_pos = vim.fn.getpos('.')

  local s = math.min(v_pos[2], dot_pos[2])
  local e = math.max(v_pos[2], dot_pos[2])

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)

  local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)

  for i, line in ipairs(lines) do
    local trimmed = line:match('^%s*(.*)')
    if trimmed:match('^%- %[ %]') or trimmed:match('^%- %[x%]') then
      lines[i] = line
    elseif trimmed:match('^[%*%+%-]') then
      lines[i] = line:gsub('^%s*([%*%+%-])%s*', '- [ ] ', 1)
    elseif trimmed:match('^%d+[%).]') then
      lines[i] = line:gsub('^%s*(%d+[%).])%s*', '- [ ] ', 1)
    else
      lines[i] = '- [ ] ' .. line
    end
  end

  vim.api.nvim_buf_set_lines(0, s - 1, e, false, lines)
  vim.api.nvim_feedkeys('gv', 'x', false)
end, {
  silent = true,
  desc = 'Convert selection to checklist',
})
