local fn_wrap = require('jg.file-tree.fn').wrap

local M = {}

function M.get_var(name)
  local ok, result = pcall(vim.api.nvim_get_var, name)
  if not ok then
    return nil
  end
  return result
end

function M.set_var(name, value)
  local ok, _ = pcall(vim.api.nvim_set_var, name, value)
  return ok
end

function M.get_option(b, name)
  local ok, result = pcall(vim.api.nvim_get_option, name)
  if not ok then
    return nil
  end
  return result
end

local onGroupTpl = 'jg.file-tree.au-%s'
local onTpl = 'autocmd %s %s %s'
local onIdx = 0

function M.on(evt, pattern, fn)
  onIdx = onIdx + 1
  local grp = onGroupTpl:format(onIdx)
  local cmd, dispose = fn_wrap(fn)

  vim.cmd('augroup ' .. grp)
  vim.cmd(onTpl:format(evt, pattern, cmd))
  vim.cmd('augroup END')

  return function()
    vim.cmd('augroup ' .. grp)
    vim.cmd('autocmd!')
    vim.cmd('augroup END')

    dispose()
  end
end

return M
