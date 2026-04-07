if vim.g.did_load_jupytext_plugin then
  return
end
vim.g.did_load_jupytext_plugin = true

local function shell_unescape(token)
  if type(token) ~= 'string' or token == '' then
    return nil
  end

  local value = vim.fn.system({ 'sh', '-lc', 'printf %s ' .. token })
  if vim.v.shell_error ~= 0 then
    return nil
  end

  return value
end

local function fallback_markdown_from_ipynb(input_token, output_token)
  local input_path = shell_unescape(input_token)
  local output_path = shell_unescape(output_token)
  if input_path == nil or output_path == nil then
    return false
  end

  local ok_lines, lines = pcall(vim.fn.readfile, input_path)
  if not ok_lines then
    return false
  end

  local ok_notebook, notebook = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not ok_notebook or type(notebook) ~= 'table' or type(notebook.cells) ~= 'table' then
    return false
  end

  local metadata = notebook.metadata or {}
  local kernelspec = metadata.kernelspec or {}
  local language_info = metadata.language_info or {}
  local jupytext = metadata.jupytext or {}
  local language = kernelspec.language or language_info.name or jupytext.main_language or 'python'

  local md = {}
  for _, cell in ipairs(notebook.cells) do
    if cell.cell_type == 'markdown' then
      vim.list_extend(md, cell.source or { '' })
      table.insert(md, '')
    elseif cell.cell_type == 'code' then
      table.insert(md, ('```%s'):format(language))
      vim.list_extend(md, cell.source or { '' })
      table.insert(md, '```')
      table.insert(md, '')
    end
  end

  local ok_write = pcall(vim.fn.writefile, md, output_path)
  return ok_write
end

local function jupytext_command_candidates()
  local candidates = {}
  if vim.fn.executable('jupytext') == 1 then
    table.insert(candidates, 'jupytext')
  end

  local host_python = vim.g.python3_host_prog
  if type(host_python) == 'string' and host_python ~= '' and vim.fn.executable(host_python) == 1 then
    table.insert(candidates, ('%s -m jupytext'):format(vim.fn.shellescape(host_python)))
  end

  return candidates
end

local function fallback_ipynb_metadata(filename)
  local file = io.open(filename, 'r')
  if file == nil then
    return { language = 'python', extension = 'py' }
  end

  local raw = file:read('a')
  file:close()
  if raw == nil or raw == '' then
    return { language = 'python', extension = 'py' }
  end

  local ok, notebook = pcall(vim.json.decode, raw)
  if not ok or type(notebook) ~= 'table' then
    return { language = 'python', extension = 'py' }
  end

  local metadata = notebook.metadata or {}
  local kernelspec = metadata.kernelspec or {}
  local language_info = metadata.language_info or {}
  local jupytext = metadata.jupytext or {}

  local language = kernelspec.language or language_info.name or jupytext.main_language or 'python'
  local extension_map = {
    python = 'py',
    julia = 'jl',
    r = 'r',
    R = 'r',
    bash = 'sh',
    sh = 'sh',
    lua = 'lua',
  }

  return {
    language = language,
    extension = extension_map[language] or language,
  }
end

local ok_utils, jupytext_utils = pcall(require, 'jupytext.utils')
if ok_utils and type(jupytext_utils.get_ipynb_metadata) == 'function' then
  local original_get_ipynb_metadata = jupytext_utils.get_ipynb_metadata
  jupytext_utils.get_ipynb_metadata = function(filename)
    local ok, metadata = pcall(original_get_ipynb_metadata, filename)
    if ok and type(metadata) == 'table' and metadata.language ~= nil and metadata.extension ~= nil then
      return metadata
    end

    return fallback_ipynb_metadata(filename)
  end
end

local ok_commands, jupytext_commands = pcall(require, 'jupytext.commands')
if ok_commands and type(jupytext_commands.run_jupytext_command) == 'function' then
  jupytext_commands.run_jupytext_command = function(input_file, options)
    local args = { input_file }
    for option_name, option_value in pairs(options) do
      if option_value ~= '' then
        table.insert(args, option_name .. '=' .. option_value)
      else
        table.insert(args, option_name)
      end
    end

    local attempted = {}
    local last_output = ''
    for _, candidate in ipairs(jupytext_command_candidates()) do
      local cmd = candidate .. ' ' .. table.concat(args, ' ')
      local output = vim.fn.system(cmd)
      table.insert(attempted, cmd)
      if vim.v.shell_error == 0 then
        return
      end
      last_output = output
    end

    if options['--to'] ~= nil and options['--output'] ~= nil and options['--update'] == nil then
      if fallback_markdown_from_ipynb(input_file, options['--output']) then
        vim.notify(
          'jupytext failed; used notebook metadata fallback conversion for this open.',
          vim.log.levels.WARN
        )
        return
      end
    end

    local command_summary = #attempted > 0 and table.concat(attempted, '\n') or '(no jupytext command candidate found)'
    vim.notify(
      ('jupytext conversion failed. Commands tried:\n%s\n\nLast output:\n%s'):format(command_summary, last_output),
      vim.log.levels.ERROR
    )
  end
end

require('jupytext').setup {
  style = 'markdown',
  output_extension = 'md',
  force_ft = 'markdown',
}
