local M = {}

function M.get_var(b, name)
  local ok, result = pcall(vim.api.nvim_tabpage_get_var, b, name)
  if not ok then
    return nil
  end
  return result
end

function M.set_var(b, name, value)
  local ok, _ = pcall(vim.api.nvim_tabpage_set_var, b, name, value)
  return ok
end

function M.get_current()
  return vim.api.nvim_get_current_tabpage()
end

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
