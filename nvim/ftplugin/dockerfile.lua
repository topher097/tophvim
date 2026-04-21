vim.treesitter.query.set(
  'dockerfile',
  'injections',
  [[
((comment) @injection.content
  (#set! injection.language "comment"))

((shell_command) @injection.content
  (#set! injection.language "bash")
  (#set! injection.include-children))

((run_instruction
  (heredoc_block) @injection.content)
  (#set! injection.language "bash")
  (#set! injection.include-children))
]]
)

if vim.fn.executable('docker-langserver') ~= 1 then
  return
end

local root_files = {
  'Dockerfile',
  '.git',
}

vim.lsp.start {
  name = 'dockerfile_langserver',
  cmd = { 'docker-langserver', '--stdio' },
  root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
  capabilities = require('user.lsp').make_client_capabilities(),
}
