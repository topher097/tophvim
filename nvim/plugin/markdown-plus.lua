if vim.g.did_load_markdown_plus_plugin then
  return
end
vim.g.did_load_markdown_plus_plugin = true

require('markdown-plus').setup {
  keymaps = {
    enabled = false,
  },
  table = {
    keymaps = {
      enabled = false,
    },
  },
}

local map = vim.keymap.set

-- formatting
map('n', '<leader>mb', '<Plug>(MarkdownPlusBold)', { desc = '[m]arkdown [b]old' })
map('x', '<leader>mb', '<Plug>(MarkdownPlusBold)', { desc = '[m]arkdown [b]old' })
map('n', '<leader>mi', '<Plug>(MarkdownPlusItalic)', { desc = '[m]arkdown [i]talic' })
map('x', '<leader>mi', '<Plug>(MarkdownPlusItalic)', { desc = '[m]arkdown [i]talic' })
map('n', '<leader>mS', '<Plug>(MarkdownPlusStrikeThrough)', { desc = '[m]arkdown [S]trikethrough' })
map('x', '<leader>mS', '<Plug>(MarkdownPlusStrikeThrough)', { desc = '[m]arkdown [S]trikethrough' })
map('n', '<leader>m`', '<Plug>(MarkdownPlusInlineCode)', { desc = '[m]arkdown inline [`]code' })
map('x', '<leader>m`', '<Plug>(MarkdownPlusInlineCode)', { desc = '[m]arkdown inline [`]code' })
map('n', '<leader>m=', '<Plug>(MarkdownPlusHighlight)', { desc = '[m]arkdown highlight [=]' })
map('x', '<leader>m=', '<Plug>(MarkdownPlusHighlight)', { desc = '[m]arkdown highlight [=]' })
map('n', '<leader>mu', '<Plug>(MarkdownPlusUnderline)', { desc = '[m]arkdown [u]nderline' })
map('x', '<leader>mu', '<Plug>(MarkdownPlusUnderline)', { desc = '[m]arkdown [u]nderline' })
map('n', '<leader>mF', '<Plug>(MarkdownPlusClearFormatting)', { desc = '[m]arkdown [F]ormat clear' })
map('x', '<leader>mF', '<Plug>(MarkdownPlusClearFormatting)', { desc = '[m]arkdown [F]ormat clear' })
map('x', '<leader>mme', '<Plug>(MarkdownPlusEscapeSelection)', { desc = '[m]arkdown [m] [e]scape punctuation' })
map('x', '<leader>mmw', '<Plug>(MarkdownPlusCodeBlockWrap)', { desc = '[m]arkdown [m] [w]rap in code block' })

-- code blocks
map('n', '<leader>mc', '<Plug>(MarkdownPlusCodeBlockInsert)', { desc = '[m]arkdown [c]ode block insert' })
map('x', '<leader>mc', '<Plug>(MarkdownPlusCodeBlockInsert)', { desc = '[m]arkdown [c]ode block wrap' })
map('n', '<leader>mC', '<Plug>(MarkdownPlusCodeBlockChangeLanguage)', { desc = '[m]arkdown [C]hange code lang' })
map('n', '[b', '<Plug>(MarkdownPlusCodeBlockPrev)', { desc = 'Prev code block' })
map('n', ']b', '<Plug>(MarkdownPlusCodeBlockNext)', { desc = 'Next code block' })

-- headers
map('n', '<leader>mh1', '<Plug>(MarkdownPlusHeader1)', { desc = '[m]arkdown [h]eader 1' })
map('n', '<leader>mh2', '<Plug>(MarkdownPlusHeader2)', { desc = '[m]arkdown [h]eader 2' })
map('n', '<leader>mh3', '<Plug>(MarkdownPlusHeader3)', { desc = '[m]arkdown [h]eader 3' })
map('n', '<leader>mh4', '<Plug>(MarkdownPlusHeader4)', { desc = '[m]arkdown [h]eader 4' })
map('n', '<leader>mh5', '<Plug>(MarkdownPlusHeader5)', { desc = '[m]arkdown [h]eader 5' })
map('n', '<leader>mh6', '<Plug>(MarkdownPlusHeader6)', { desc = '[m]arkdown [h]eader 6' })
map('n', '<leader>mh+', '<Plug>(MarkdownPlusHeaderPromote)', { desc = '[m]arkdown [h]eader promote' })
map('n', '<leader>mh-', '<Plug>(MarkdownPlusHeaderDemote)', { desc = '[m]arkdown [h]eader demote' })
map('n', '<leader>mht', '<Plug>(MarkdownPlusTocGenerate)', { desc = '[m]arkdown [h]eaders [t]oc generate' })
map('n', '<leader>mhu', '<Plug>(MarkdownPlusTocUpdate)', { desc = '[m]arkdown [h]eaders toc [u]pdate' })
map('n', '<leader>mhs', '<Plug>(MarkdownPlusHeadingStyleToggle)', { desc = '[m]arkdown [h]eading [s]tyle toggle' })
map('n', ']]', '<Plug>(MarkdownPlusNextHeader)', { desc = 'Next header' })
map('n', '[[', '<Plug>(MarkdownPlusPrevHeader)', { desc = 'Prev header' })

-- thematic breaks
map('n', '<leader>mhh', '<Plug>(MarkdownPlusInsertThematicBreak)', { desc = '[m]arkdown [h]orizontal break' })
map('n', '<leader>mH', '<Plug>(MarkdownPlusCycleThematicBreak)', { desc = '[m]arkdown cycle break [H]' })

-- links
map('n', '<leader>ml', '<Plug>(MarkdownPlusLinkInsert)', { desc = '[m]arkdown [l]ink insert' })
map('x', '<leader>ml', '<Plug>(MarkdownPlusLinkInsert)', { desc = '[m]arkdown [l]ink from selection' })
map('n', '<leader>mle', '<Plug>(MarkdownPlusLinkEdit)', { desc = '[m]arkdown [l]ink [e]dit' })
map('n', '<leader>mla', '<Plug>(MarkdownPlusLinkAutoConvert)', { desc = '[m]arkdown [l]ink [a]uto convert' })
map('n', '<leader>mlR', '<Plug>(MarkdownPlusLinkToReference)', { desc = '[m]arkdown [l]ink to [R]eference' })
map('n', '<leader>mlI', '<Plug>(MarkdownPlusLinkToInline)', { desc = '[m]arkdown [l]ink to [I]nline' })
map('n', '<leader>mlp', '<Plug>(MarkdownPlusLinkSmartPaste)', { desc = '[m]arkdown [l]ink [p]aste' })

-- images
map('n', '<leader>mL', '<Plug>(MarkdownPlusImageInsert)', { desc = '[m]arkdown image [L]ink' })
map('x', '<leader>mL', '<Plug>(MarkdownPlusImageInsert)', { desc = '[m]arkdown image from selection' })
map('n', '<leader>mE', '<Plug>(MarkdownPlusImageEdit)', { desc = '[m]arkdown image [E]dit' })
map('n', '<leader>mA', '<Plug>(MarkdownPlusImageToggle)', { desc = '[m]arkdown link/image [A]toggle' })

-- quotes and callouts
map('n', '<leader>mq', '<Plug>(MarkdownPlusBlockquoteToggle)', { desc = '[m]arkdown [q]uote toggle' })
map('x', '<leader>mq', '<Plug>(MarkdownPlusBlockquoteToggle)', { desc = '[m]arkdown [q]uote toggle' })
map('n', '<leader>mQi', '<Plug>(MarkdownPlusCalloutInsert)', { desc = '[m]arkdown callout [i]nsert' })
map('n', '<leader>mQt', '<Plug>(MarkdownPlusCalloutToggle)', { desc = '[m]arkdown callout [t]oggle' })
map('n', '<leader>mQc', '<Plug>(MarkdownPlusBlockquoteToCallout)', { desc = '[m]arkdown quote to [c]allout' })
map('n', '<leader>mQb', '<Plug>(MarkdownPlusCalloutToBlockquote)', { desc = '[m]arkdown callout to [b]lockquote' })

-- lists and checkboxes
map('n', '<leader>mx', '<Plug>(MarkdownPlusCheckboxToggle)', { desc = '[m]arkdown checkbo[x] toggle' })
map('x', '<leader>mx', '<Plug>(MarkdownPlusCheckboxToggle)', { desc = '[m]arkdown checkbo[x] toggle' })
map('n', '<leader>mr', '<Plug>(MarkdownPlusListRenumber)', { desc = '[m]arkdown [r]enumber lists' })
map('n', '<leader>md', '<Plug>(MarkdownPlusListDebug)', { desc = '[m]arkdown [d]ebug lists' })

-- footnotes
map('n', '<leader>mfi', '<Plug>(MarkdownPlusFootnoteInsert)', { desc = '[m]arkdown [f]ootnote [i]nsert' })
map('n', '<leader>mfe', '<Plug>(MarkdownPlusFootnoteEdit)', { desc = '[m]arkdown [f]ootnote [e]dit' })
map('n', '<leader>mfd', '<Plug>(MarkdownPlusFootnoteDelete)', { desc = '[m]arkdown [f]ootnote [d]elete' })
map('n', '<leader>mfg', '<Plug>(MarkdownPlusFootnoteGoto)', { desc = '[m]arkdown [f]ootnote [g]oto' })
map('n', '<leader>mfr', '<Plug>(MarkdownPlusFootnoteReference)', { desc = '[m]arkdown [f]ootnote [r]eference' })
map('n', '<leader>mfn', '<Plug>(MarkdownPlusFootnoteNext)', { desc = '[m]arkdown [f]ootnote [n]ext' })
map('n', '<leader>mfp', '<Plug>(MarkdownPlusFootnotePrev)', { desc = '[m]arkdown [f]ootnote [p]rev' })
map('n', '<leader>mfl', '<Plug>(MarkdownPlusFootnoteList)', { desc = '[m]arkdown [f]ootnote [l]ist' })

-- table operations (<leader>mt*)
map('n', '<leader>mtc', '<Plug>(MarkdownPlusTableCreate)', { desc = '[m]arkdown [t]able [c]reate' })
map('n', '<leader>mtf', '<Plug>(MarkdownPlusTableFormat)', { desc = '[m]arkdown [t]able [f]ormat' })
map('n', '<leader>mtn', '<Plug>(MarkdownPlusTableNormalize)', { desc = '[m]arkdown [t]able [n]ormalize' })
map(
  'n',
  '<leader>mtir',
  '<Plug>(MarkdownPlusTableInsertRowBelow)',
  { desc = '[m]arkdown [t]able [i]nsert [r]ow below' }
)
map(
  'n',
  '<leader>mtiR',
  '<Plug>(MarkdownPlusTableInsertRowAbove)',
  { desc = '[m]arkdown [t]able [i]nsert [R]ow above' }
)
map('n', '<leader>mtdr', '<Plug>(MarkdownPlusTableDeleteRow)', { desc = '[m]arkdown [t]able [d]elete [r]ow' })
map('n', '<leader>mtyr', '<Plug>(MarkdownPlusTableDuplicateRow)', { desc = '[m]arkdown [t]able [y]ank [r]ow' })
map(
  'n',
  '<leader>mtic',
  '<Plug>(MarkdownPlusTableInsertColumnRight)',
  { desc = '[m]arkdown [t]able [i]nsert [c]ol right' }
)
map(
  'n',
  '<leader>mtiC',
  '<Plug>(MarkdownPlusTableInsertColumnLeft)',
  { desc = '[m]arkdown [t]able [i]nsert [C]ol left' }
)
map('n', '<leader>mtdc', '<Plug>(MarkdownPlusTableDeleteColumn)', { desc = '[m]arkdown [t]able [d]elete [c]ol' })
map('n', '<leader>mtyc', '<Plug>(MarkdownPlusTableDuplicateColumn)', { desc = '[m]arkdown [t]able [y]ank [c]ol' })
map('n', '<leader>mta', '<Plug>(MarkdownPlusTableToggleAlignment)', { desc = '[m]arkdown [t]able [a]lignment' })
map('n', '<leader>mtx', '<Plug>(MarkdownPlusTableClearCell)', { desc = '[m]arkdown [t]able clear [x]' })
map('n', '<leader>mtmj', '<Plug>(MarkdownPlusTableMoveRowDown)', { desc = '[m]arkdown [t]able [m]ove row [j]' })
map('n', '<leader>mtmk', '<Plug>(MarkdownPlusTableMoveRowUp)', { desc = '[m]arkdown [t]able [m]ove row [k]' })
map('n', '<leader>mtml', '<Plug>(MarkdownPlusTableMoveColumnRight)', { desc = '[m]arkdown [t]able [m]ove col [l]' })
map('n', '<leader>mtmh', '<Plug>(MarkdownPlusTableMoveColumnLeft)', { desc = '[m]arkdown [t]able [m]ove col [h]' })
map('n', '<leader>mtt', '<Plug>(MarkdownPlusTableTranspose)', { desc = '[m]arkdown [t]able [t]ranspose' })
map('n', '<leader>mtsa', '<Plug>(MarkdownPlusTableSortAsc)', { desc = '[m]arkdown [t]able [s]ort [a]sc' })
map('n', '<leader>mtsd', '<Plug>(MarkdownPlusTableSortDesc)', { desc = '[m]arkdown [t]able [s]ort [d]esc' })
map('n', '<leader>mtvx', '<Plug>(MarkdownPlusTableToCsv)', { desc = '[m]arkdown [t]able to csv' })
map('n', '<leader>mtvi', '<Plug>(MarkdownPlusTableFromCsv)', { desc = '[m]arkdown [t]able from csv' })

-- custom checklist conversion
map('v', '<leader>ms', function()
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
