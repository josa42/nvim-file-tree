local M = {}

function M.findBuffer(fn)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local ok, result = pcall(fn, b)
    if ok and result then
      return b
    end
  end

  return -1
end

function M.findWindow(fn)
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local ok, result = pcall(fn, w)
    if ok and result then
      return w
    end
  end

  return -1
end

function M.findTabpageWindow(t, fn)
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
    local b = vim.api.nvim_win_get_buf(w)
    local ok, result = pcall(fn, w, b)
    if ok and result then
      return w
    end
  end

  return -1
end

function M.tabpageHasBuffer(t, b)
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
    local wb = vim.api.nvim_win_get_buf(w)
    if wb == b then
      return true
    end
  end

  return false
end

return M
