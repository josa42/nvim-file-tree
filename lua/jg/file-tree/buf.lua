local fn_wrap = require('jg.file-tree.fn').wrap

local M = {}

function M.get_var(b, name)
  local ok, result = pcall(vim.api.nvim_buf_get_var, b, name)
  if not ok then
    return nil
  end
  return result
end

function M.set_var(b, name, value)
  local ok, _ = pcall(vim.api.nvim_buf_set_var, b, name, value)
  return ok
end

function M.get_option(b, name)
  local ok, result = pcall(vim.api.nvim_buf_get_option, b, name)
  if not ok then
    return nil
  end
  return result
end

function M.set_option(b, name, value)
  local ok, _ = pcall(vim.api.nvim_buf_set_option, b, name, value)
  return ok
end

function M.set_lines(b, lines)
  local ok, e = pcall(vim.api.nvim_buf_set_lines, b, 0, -1, false, lines)
  return ok
end

function M.close(b)
  if b > 0 then
    pcall(vim.api.nvim_buf_detach, b)
    vim.cmd('bwipeout ' .. b)
  end
end

local onTpl = 'autocmd %s <buffer=%s> %s'

function M.on(b, evt, fn)
  local cmd, dispose = fn_wrap(fn)
  vim.cmd(onTpl:format(evt, b, cmd))

  return function()
    -- TODO dispose autocmd
    dispose()
  end
end

function M.is_empty(b)
  if b ~= -1 then
    local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false) or { '' }
    return #lines <= 1 and lines[1] == ''
  end
end

return M
