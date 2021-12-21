local M = {}
-- function scandir(directory)
--   local i, t, popen = 0, {}, io.popen
--   local pfile = popen('ls -a "' .. directory .. '"')
--   for filename in pfile:lines() do
--     i = i + 1
--     t[i] = filename
--   end
--   pfile:close()
--   return t
-- end

function M.read_dir(path)
  local p = '*'
  if path or path ~= '.' then
    p = M.join(path, '*')
  end

  local names = {}
  for _, cpath in ipairs(vim.fn.glob(p, false, true)) do
    table.insert(names, M.basename(cpath))
  end

  return names
end

function M.is_dir(path)
  return vim.fn.isdirectory(path) == 1
end

function M.basename(path)
  local name = path:gsub('(.*/)(.*)', '%2')
  return name
end

function M.join(...)
  return table.concat({ ... }, '/')
end

return M
