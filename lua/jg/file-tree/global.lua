local fn = require('jg.file-tree.fn')

local M = {}

M.get_var = fn.wrap_pcall(vim.api.nvim_get_var)
M.set_var = fn.wrap_pcall(vim.api.nvim_set_var)

M.get_option = fn.wrap_pcall(vim.api.nvim_get_option)
M.set_option = fn.wrap_pcall(vim.api.nvim_set_option)

local onGroupTpl = 'jg.file-tree.au-%s'
local onTpl = 'autocmd %s %s %s'
local onIdx = 0

function M.on(evt, pattern, handler)
  onIdx = onIdx + 1
  local grp = onGroupTpl:format(onIdx)
  local cmd, dispose = fn.wrap(handler)

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
