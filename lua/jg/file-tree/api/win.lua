local fn = require('jg.file-tree.api.fn')

local M = {}

M.get_var = fn.wrap_pcall(vim.api.nvim_win_get_var)
M.set_var = fn.wrap_pcall(vim.api.nvim_win_set_var)

M.get_current = vim.api.nvim_get_current_win
M.set_current = vim.api.nvim_set_current_win

function M.get_buf(win)
  return vim.api.nvim_win_get_buf(win)
end

function M.find(fn)
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local ok, result = pcall(fn, w)
    if ok and result then
      return w
    end
  end

  return -1
end

function M.find_by_path(path)
  return M.find(function(w)
    return path == vim.fn.expand('#' .. M.get_buf(w) .. ':p')
  end)
end

return M
