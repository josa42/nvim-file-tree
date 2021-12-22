local fn = require('jg.file-tree.api.fn')
local g = require('jg.file-tree.api.global')

local M = {}

M.get_var = fn.wrap_pcall(vim.api.nvim_buf_get_var)
M.set_var = fn.wrap_pcall(vim.api.nvim_buf_set_var)

M.get_option = fn.wrap_pcall(vim.api.nvim_buf_get_option)
M.set_option = fn.wrap_pcall(vim.api.nvim_buf_set_option)

function M.set_lines(b, lines)
  local ok = pcall(vim.api.nvim_buf_set_lines, b, 0, -1, false, lines)
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

function M.on(b, evt, handler)
  return g.on(evt, onTpl:format(b), handler)
end

function M.is_empty(b)
  if b ~= -1 then
    local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false) or { '' }
    return #lines <= 1 and lines[1] == ''
  end
end

function M.find(cb)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local ok, result = pcall(cb, b)
    if ok and result then
      return b
    end
  end

  return -1
end

local mapCmdTpl = ':%s<cr>'

function M.set_keymap(b, mode, key, handler, opts)
  opts = opts or { silent = true, noremap = true }

  if type(handler) ~= 'string' then
    handler = mapCmdTpl:format(fn.wrap(handler))
  end

  vim.api.nvim_buf_set_keymap(b, mode, key, handler, opts)

  return function()
    -- TODO dispose
  end
end

return M
