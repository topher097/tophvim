if vim.g.did_load_jupytext_plugin then
  return
end
vim.g.did_load_jupytext_plugin = true

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

require('jupytext').setup {
  style = 'markdown',
  output_extension = 'md',
  force_ft = 'markdown',
}
