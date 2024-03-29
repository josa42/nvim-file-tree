local fn = require('file-tree.api.fn')

local M = {}

function M.set_lines(b, lines)
  local ok = pcall(vim.api.nvim_buf_set_lines, b, 0, -1, false, lines)
  return ok
end

function M.close(b)
  if b > 0 then
    pcall(vim.api.nvim_buf_detach, b)
    vim.cmd.bwipeout(b)
  end
end

function M.get_current()
  return vim.api.nvim_get_current_buf()
end

function M.set_name(b, name)
  vim.api.nvim_buf_set_name(b, name)
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

return M
