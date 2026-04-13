if vim.g.did_load_commands_plugin then
  return
end
vim.g.did_load_commands_plugin = true

local api = vim.api

-- delete current buffer
api.nvim_create_user_command('Q', 'bd % <CR>', {})

-- Create a new blank Jupyter notebook.
-- The metadata is needed for Jupytext to understand how to parse the notebook.
local default_notebook = [[
{
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        ""
      ]
    }
  ],
  "metadata": {
    "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
    },
    "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
    }
  },
  "nbformat": 4,
  "nbformat_minor": 5
}
]]

local function new_notebook(filename)
  local path = filename
  if not path:match('%.ipynb$') then
    path = path .. '.ipynb'
  end

  if vim.uv.fs_stat(path) then
    vim.notify(('Notebook already exists: %s'):format(path), vim.log.levels.ERROR)
    return
  end

  local file = io.open(path, 'w')
  if file then
    file:write(default_notebook)
    file:close()
    vim.cmd.edit(path)
  else
    vim.notify('Error: Could not open new notebook file for writing.', vim.log.levels.ERROR)
  end
end

api.nvim_create_user_command('NewNotebook', function(opts)
  new_notebook(opts.args)
end, {
  nargs = 1,
  complete = 'file',
})
