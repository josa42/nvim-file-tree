local g = require('jg.file-tree.global')

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

function M.get_current()
  return vim.api.nvim_get_current_buf()
end

function M.set_name(b, name)
  vim.api.nvim_buf_set_name(b, name)
end

local onTpl = '<buffer=%s>'

function M.on(b, evt, fn)
  return g.on(evt, onTpl:format(b), fn)
end

function M.is_empty(b)
  if b ~= -1 then
    local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false) or { '' }
    return #lines <= 1 and lines[1] == ''
  end
end

function M.find(fn)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local ok, result = pcall(fn, b)
    if ok and result then
      return b
    end
  end

  return -1
end

return M
