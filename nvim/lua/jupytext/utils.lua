local M = {}

local language_extensions = {
  python = 'py',
  julia = 'jl',
  r = 'r',
  R = 'r',
  bash = 'sh',
  sh = 'sh',
  lua = 'lua',
}

local language_names = {
  python3 = 'python',
}

local function read_notebook_metadata(filename)
  local file = io.open(filename, 'r')
  if file == nil then
    return {}
  end

  local raw = file:read('a')
  file:close()
  if raw == nil or raw == '' then
    return {}
  end

  local ok, notebook = pcall(vim.json.decode, raw)
  if not ok or type(notebook) ~= 'table' then
    return {}
  end

  return notebook.metadata or {}
end

M.get_ipynb_metadata = function(filename)
  local metadata = read_notebook_metadata(filename)
  local kernelspec = metadata.kernelspec or {}
  local language_info = metadata.language_info or {}
  local jupytext = metadata.jupytext or {}

  local language = kernelspec.language
    or language_names[kernelspec.name]
    or language_info.name
    or jupytext.main_language
    or 'python'

  local extension = language_extensions[language] or language

  return { language = language, extension = extension }
end

M.get_jupytext_file = function(filename, extension)
  local fileroot = vim.fn.fnamemodify(filename, ':r')
  return fileroot .. '.' .. extension
end

M.check_key = function(tbl, key)
  for tbl_key, _ in pairs(tbl) do
    if tbl_key == key then
      return true
    end
  end

  return false
end

return M
