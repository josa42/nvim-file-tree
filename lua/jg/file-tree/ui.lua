local M = {}

-- func (s SplitModifier) String() string {
-- 	switch s {
-- 	case SplitVertical:
-- 		return "vertical"
-- 	case SplitHorizontal:
-- 		return "horizontal"
-- 	case SplitTopLeft:
-- 		return "topleft"
-- 	case SplitBottomRight:
-- 		return "botright"
-- 	default:
-- 		return ""
-- 	}
-- }

-- function M.createSplitBuffer(width, ...)
--   vim.cmd(table.concat(... and { ... } or { 'topleft', 'vertical' }, ' ') .. ' ' .. width .. ' new')
--   return vim.api.nvim_get_current_buf()
-- end

function M.findBuffer(fn)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local ok, result = pcall(fn, b)
    if ok and result then
      return b
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
