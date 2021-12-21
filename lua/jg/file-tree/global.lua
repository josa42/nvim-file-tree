local M = {}

function M.get_var(name)
  local ok, result = pcall(vim.api.nvim_get_var, name)
  if not ok then
    D(result)
    return nil
  end
  return result
end

function M.set_var(name, value)
  local ok, _ = pcall(vim.api.nvim_set_var, name, value)
  return ok
end

function M.get_option(b, name)
  local ok, result = pcall(vim.api.nvim_get_option, name)
  if not ok then
    return nil
  end
  return result
end

return M
