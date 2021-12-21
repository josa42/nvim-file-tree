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

return M
