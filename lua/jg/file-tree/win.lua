local M = {}

function M.get_var(w, name)
  local ok, result = pcall(vim.api.nvim_win_get_var, w, name)
  if not ok then
    return nil
  end
  return result
end

function M.set_var(w, name, value)
  local ok, _ = pcall(vim.api.nvim_win_set_var, w, name, value)
  return ok
end

function M.get_current()
  return vim.api.nvim_get_current_win()
end

function M.set_current(win)
  return vim.api.nvim_set_current_win(win)
end

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
