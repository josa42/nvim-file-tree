local M = {}

function M.read_dir(path)
  local names = {}

  local fd = vim.loop.fs_scandir(path)
  if fd then
    while true do
      local name = vim.loop.fs_scandir_next(fd)
      if name == nil then
        break
      end
      table.insert(names, name)
    end
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
