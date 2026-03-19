if vim.g.did_load_render_markdown_plugin then
  return
end
vim.g.did_load_render_markdown_plugin = true

require('render-markdown').setup {}
