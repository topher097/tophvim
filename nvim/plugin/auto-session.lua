if vim.g.did_load_auto_session_plugin then
  return
end
vim.g.did_load_auto_session_plugin = true

local function load_direnv_for_cwd(cwd)
  if vim.fn.executable('direnv') ~= 1 then
    return
  end

  local dir = cwd or vim.fn.getcwd()
  local result = vim.fn.system({ 'direnv', 'export', 'json' }, dir)
  if vim.v.shell_error ~= 0 then
    return
  end

  local ok, env = pcall(vim.json.decode, result)
  if not ok or type(env) ~= 'table' then
    return
  end

  local seen = {}
  for key, value in pairs(env) do
    if type(key) == 'string' then
      seen[key] = true
      if value == vim.NIL or value == nil then
        vim.env[key] = nil
      else
        vim.env[key] = tostring(value)
      end
    end
  end

  -- If direnv did not include these vars, clear stale values inherited from launch cwd.
  if not seen.VIRTUAL_ENV then
    vim.env.VIRTUAL_ENV = nil
  end
  if not seen.CONDA_PREFIX then
    vim.env.CONDA_PREFIX = nil
  end
end

local function extract_session_path_from_line(line)
  return line:match('^badd%s+%+%d+%s+(.+)$')
    or line:match('^badd%s+(.+)$')
    or line:match('^edit%s+(.+)$')
    or line:match('^balt%s+(.+)$')
    or line:match('^argadd%s+(.+)$')
end

local function resolve_session_file_path(path, session_cwd)
  local unescaped = path:gsub('\\ ', ' ')
  local expanded = vim.fn.expand(unescaped)
  if session_cwd ~= nil and session_cwd ~= '' and not vim.startswith(expanded, '/') then
    expanded = session_cwd .. '/' .. expanded
  end
  return vim.fn.fnamemodify(expanded, ':p')
end

local function find_session_file_path(session_name)
  local auto_session = require('auto-session')
  local lib = require('auto-session.lib')
  local root = auto_session.get_root_dir()

  for _, session_path in ipairs(vim.fn.glob(root .. '*.vim', false, true)) do
    local filename = vim.fn.fnamemodify(session_path, ':t')
    if lib.get_session_display_name(filename) == session_name then
      return session_path
    end
  end

  local direct = root .. lib.escape_session_name(session_name) .. '.vim'
  if vim.fn.filereadable(direct) == 1 then
    return direct
  end

  local legacy = root .. lib.legacy_escape_session_name(session_name) .. '.vim'
  if vim.fn.filereadable(legacy) == 1 then
    return legacy
  end

  return nil
end

local function prune_missing_paths_from_session(session_path)
  if session_path == nil or vim.fn.filereadable(session_path) ~= 1 then
    return 0
  end

  local lines = vim.fn.readfile(session_path)
  local cleaned = {}
  local removed = 0
  local session_cwd = nil

  for _, line in ipairs(lines) do
    local cd_path = line:match('^cd%s+(.+)$')
    if cd_path then
      session_cwd = vim.fn.fnamemodify(vim.fn.expand(cd_path), ':p')
      table.insert(cleaned, line)
    else
      local maybe_path = extract_session_path_from_line(line)
      if maybe_path == nil or maybe_path:match('^%w[%w+.-]*://') then
        table.insert(cleaned, line)
      else
        local resolved_path = resolve_session_file_path(maybe_path, session_cwd)
        if vim.uv.fs_stat(resolved_path) ~= nil then
          table.insert(cleaned, line)
        else
          removed = removed + 1
        end
      end
    end
  end

  if removed > 0 then
    vim.fn.writefile(cleaned, session_path)
  end

  return removed
end

local function auto_session_restore_error_handler(error_msg)
  if type(error_msg) == 'string' and (error_msg:find('E484:', 1, true) or error_msg:find('No such file', 1, true)) then
    return true
  end
  return require('auto-session').default_restore_error_handler(error_msg)
end

require('auto-session').setup {
  auto_restore = false,
  bypass_save_filetypes = { 'alpha' },
  restore_error_handler = auto_session_restore_error_handler,
  pre_restore_cmds = {
    function(session_name)
      local lib = require('auto-session.lib')
      local cwd = lib.get_session_display_name_as_table(session_name)[1]
      load_direnv_for_cwd(cwd)

      local session_path = find_session_file_path(session_name)
      local removed = prune_missing_paths_from_session(session_path)
      if removed > 0 then
        vim.notify(
          ('auto-session: skipped %d missing files while restoring %s'):format(removed, session_name),
          vim.log.levels.INFO
        )
      end

      return true
    end,
  },
}

vim.api.nvim_create_autocmd('DirChanged', {
  callback = function(event)
    local cwd = event and event.file or vim.fn.getcwd()
    load_direnv_for_cwd(cwd)
  end,
})
