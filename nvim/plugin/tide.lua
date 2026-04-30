require('tide').setup {
  keys = {
    leader = ';',
    panel = ';',
    add_item = 'a',
    delete = 'd',
    clear_all = 'x',
    horizontal = '-',
    vertical = '|',
  },
  animation_duration = 300,
  animation_fps = 30,
  hints = {
    dictionary = 'qwertzuiopsfghjklycvbnm',
  },
}
