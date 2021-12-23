local fn = require('file-tree.api.fn')

local M = {}

M.get_var = fn.wrap_pcall(vim.api.nvim_tabpage_get_var)
M.set_var = fn.wrap_pcall(vim.api.nvim_tabpage_set_var)

M.get_current = vim.api.nvim_get_current_tabpage

function M.find_window(t, fn)
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
    local b = vim.api.nvim_win_get_buf(w)
    local ok, result = pcall(fn, w, b)
    if ok and result then
      return w
    end
  end

  return -1
end

function M.has_buffer(t, b)
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
    local wb = vim.api.nvim_win_get_buf(w)
    if wb == b then
      return true
    end
  end

  return false
end

return M
