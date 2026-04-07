if vim.g.did_load_molten_plugin then
  return
end
vim.g.did_load_molten_plugin = true

-- Molten configuration
vim.g.molten_auto_open_output = true
vim.g.molten_image_provider = 'image.nvim'
vim.g.molten_wrap_output = true
vim.g.molten_virt_text_output = false
vim.g.molten_output_virt_lines = true
vim.g.molten_virt_lines_off_by_1 = false
vim.g.molten_output_win_hide_on_leave = false
vim.g.molten_output_win_max_height = 20
vim.g.molten_show_mimetype_debug = true

local keymap = vim.keymap

local initialized_ipynb_buffers = {}
local output_windows_enabled = true
local output_toggle_group = vim.api.nvim_create_augroup('MoltenOutputToggle', { clear = true })

local function set_auto_open_output(enabled)
  if require('molten.status').initialized() == 'Molten' then
    vim.fn.MoltenUpdateOption('auto_open_output', enabled)
  else
    vim.g.molten_auto_open_output = enabled
  end
end

local function enable_output_autoshow(enabled)
  vim.api.nvim_clear_autocmds { group = output_toggle_group }

  if not enabled then
    vim.cmd('MoltenHideOutput')
    return
  end

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    group = output_toggle_group,
    callback = function()
      vim.cmd('silent! MoltenShowOutput')
    end,
  })

  vim.cmd('silent! MoltenShowOutput')
end

local VENV_DIR_NAMES = { '.venv', 'venv' }

local function path_join(...)
  return table.concat({ ... }, '/')
end

local function is_executable(path)
  return vim.fn.executable(path) == 1
end

local function dedupe_paths(paths)
  local seen = {}
  local deduped = {}
  for _, path in ipairs(paths) do
    if path ~= nil and path ~= '' and not seen[path] then
      seen[path] = true
      table.insert(deduped, path)
    end
  end
  return deduped
end

local function find_project_venv_python()
  local env_venv = os.getenv('VIRTUAL_ENV') or os.getenv('CONDA_PREFIX')
  if env_venv ~= nil and env_venv ~= '' then
    local env_python = path_join(env_venv, 'bin', 'python')
    if is_executable(env_python) then
      return env_python
    end
  end

  local current_buffer = vim.api.nvim_buf_get_name(0)
  local roots = {
    vim.fn.getcwd(),
    current_buffer ~= '' and vim.fs.dirname(current_buffer) or nil,
  }

  for _, root in ipairs(dedupe_paths(roots)) do
    local found = vim.fs.find(VENV_DIR_NAMES, {
      path = root,
      upward = true,
      type = 'directory',
      stop = vim.loop.os_homedir(),
    })

    if found[1] ~= nil then
      local python = path_join(found[1], 'bin', 'python')
      if is_executable(python) then
        return python
      end
    end
  end

  return nil
end

local function sanitize_kernel_name(name)
  return (name:gsub('[^%w_.-]', '-'))
end

local function kernel_name_for_python(python_path)
  local venv_dir = vim.fs.dirname(vim.fs.dirname(python_path))
  local venv_name = vim.fs.basename(venv_dir):gsub('^%.+', '')
  local project_root = vim.fs.dirname(venv_dir)
  local project_name = vim.fs.basename(project_root)
  return sanitize_kernel_name(('molten-%s-%s'):format(project_name, venv_name))
end

local function molten_available_kernels()
  local ok, kernels = pcall(vim.fn.MoltenAvailableKernels)
  if not ok then
    vim.notify(
      ('Molten: failed to query kernels. Check remote-plugin Python deps (`pynvim`, `jupyter_client`). python3_host_prog=%s'):format(
        tostring(vim.g.python3_host_prog)
      ),
      vim.log.levels.ERROR
    )
    return nil
  end

  return kernels
end

local function has_kernel(kernels, kernel_name)
  return kernels ~= nil and vim.tbl_contains(kernels, kernel_name)
end

local function ensure_python_kernel(python_path, kernel_name)
  local kernels = molten_available_kernels()
  if has_kernel(kernels, kernel_name) then
    return true
  end

  local out = vim.fn.system {
    python_path,
    '-m',
    'ipykernel',
    'install',
    '--user',
    '--name',
    kernel_name,
    '--display-name',
    ('Python (%s)'):format(kernel_name),
  }

  if vim.v.shell_error ~= 0 then
    vim.notify(
      ('Molten: failed to install kernel %s from %s.\n%s'):format(kernel_name, python_path, out),
      vim.log.levels.WARN
    )
    return false
  end

  kernels = molten_available_kernels()
  if has_kernel(kernels, kernel_name) then
    return true
  end

  vim.notify(
    ('Molten: installed kernel %s, but it is still not visible to Molten. Run :checkhealth molten and verify Jupyter paths.'):format(
      kernel_name
    ),
    vim.log.levels.WARN
  )
  return false
end

local function maybe_init_notebook_buffer(event)
  vim.schedule(function()
    local bufnr = event and event.buf or vim.api.nvim_get_current_buf()
    if bufnr == nil then
      return
    end

    if initialized_ipynb_buffers[bufnr] then
      return
    end

    local kernels = molten_available_kernels()
    if kernels == nil then
      return
    end

    local kernel_name = nil
    local path = event and event.file or vim.api.nvim_buf_get_name(0)
    if path ~= nil and path ~= '' then
      local ok_lines, lines = pcall(vim.fn.readfile, path)
      if ok_lines then
        local ok_notebook, notebook = pcall(vim.json.decode, table.concat(lines, '\n'))
        if ok_notebook and notebook and notebook.metadata and notebook.metadata.kernelspec then
          local notebook_kernel = notebook.metadata.kernelspec.name
          if type(notebook_kernel) == 'string' and notebook_kernel ~= '' and has_kernel(kernels, notebook_kernel) then
            kernel_name = notebook_kernel
          end
        end
      end
    end

    if kernel_name == nil then
      local python = find_project_venv_python()
      if python ~= nil then
        local project_kernel = kernel_name_for_python(python)
        if ensure_python_kernel(python, project_kernel) then
          kernel_name = project_kernel
        end
      end
    end

    if kernel_name ~= nil then
      vim.cmd(('MoltenInit %s'):format(kernel_name))
    end

    initialized_ipynb_buffers[bufnr] = true
    vim.cmd('MoltenImportOutput')
  end)
end

-- Initialize kernel
keymap.set('n', '<leader>ji', function()
  local python = find_project_venv_python()
  if python == nil then
    vim.cmd('MoltenInit')
    return
  end

  local kernel_name = kernel_name_for_python(python)
  if ensure_python_kernel(python, kernel_name) then
    vim.cmd(('MoltenInit %s'):format(kernel_name))
    return
  end

  vim.cmd('MoltenInit')
end, { silent = true, desc = '[j]upyter [i]nit kernel (auto-detect venv)' })
keymap.set('n', '<leader>jI', ':MoltenInit<CR>', { silent = true, desc = '[j]upyter [I]nit kernel (pick)' })

local molten_notebook_group = vim.api.nvim_create_augroup('MoltenNotebookSetup', { clear = true })
vim.api.nvim_create_autocmd('BufAdd', {
  pattern = { '*.ipynb' },
  group = molten_notebook_group,
  callback = maybe_init_notebook_buffer,
})

vim.api.nvim_create_autocmd('BufUnload', {
  pattern = { '*.ipynb' },
  group = molten_notebook_group,
  callback = function(event)
    initialized_ipynb_buffers[event.buf] = nil
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = { '*.ipynb' },
  group = molten_notebook_group,
  callback = maybe_init_notebook_buffer,
})

vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { '*.ipynb' },
  group = molten_notebook_group,
  callback = function()
    if require('molten.status').initialized() == 'Molten' then
      vim.cmd('MoltenExportOutput!')
    end
  end,
})

-- Evaluate code
keymap.set('n', '<leader>je', ':MoltenEvaluateOperator<CR>', { silent = true, desc = '[j]upyter [e]valuate operator' })
keymap.set('n', '<leader>jl', ':MoltenEvaluateLine<CR>', { silent = true, desc = '[j]upyter run [l]ine' })
keymap.set('n', '<leader>jr', ':MoltenReevaluateCell<CR>', { silent = true, desc = '[j]upyter [r]e-evaluate cell' })
keymap.set(
  'v',
  '<leader>jv',
  ':<C-u>MoltenEvaluateVisual<CR>gv',
  { silent = true, desc = '[j]upyter run [v]isual selection' }
)

-- Output management
keymap.set(
  'n',
  '<leader>jo',
  ':noautocmd MoltenEnterOutput<CR>',
  { silent = true, desc = '[j]upyter [o]utput show/enter' }
)
keymap.set('n', '<leader>jh', function()
  output_windows_enabled = not output_windows_enabled
  set_auto_open_output(output_windows_enabled)
  enable_output_autoshow(output_windows_enabled)
end, { silent = true, desc = '[j]upyter toggle [h]ide/show output windows' })
keymap.set('n', '<leader>jd', ':MoltenDelete<CR>', { silent = true, desc = '[j]upyter [d]elete cell' })

-- Notebook import/export
keymap.set('n', '<leader>jp', ':MoltenImportOutput<CR>', { silent = true, desc = '[j]upyter im[p]ort output' })
keymap.set('n', '<leader>jx', ':MoltenExportOutput!<CR>', { silent = true, desc = '[j]upyter e[x]port output' })

enable_output_autoshow(output_windows_enabled)
