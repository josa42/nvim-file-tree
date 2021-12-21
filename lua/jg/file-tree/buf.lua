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

M.__on_handler = {}
local onTpl = 'autocmd %s <buffer=%s> call v:lua.require("jg.file-tree.buf").__on_handler[%s]()'

function M.on(b, evt, fn)
  table.insert(M.__on_handler, fn)
  vim.cmd(onTpl:format(evt, b, #M.__on_handler))

  -- local idx = #M.__on_handler
  -- vim.cmd(
  --   'autocmd ' .. evt .. ' <buffer=' .. b .. '> call v:lua.require("jg.file-tree.buf").__on_handler[' .. idx .. ']()'
  -- )

  -- TODO dispose
  return function() end
end

return M
