if vim.g.did_load_image_plugin then
  return
end
vim.g.did_load_image_plugin = true

require('image').setup {
  backend = 'kitty',
  processor = 'magick_rock',
  integrations = {},
  -- 2x larger than previous defaults, but still clamp to current window size.
  max_width = 200,
  max_height = 24,
  max_height_window_percentage = 100,
  max_width_window_percentage = 100,
  window_overlap_clear_enabled = true,
  window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
}
