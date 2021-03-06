local M = {}

M.enabled = false
M.file_path = os.getenv('HOME') .. '/tmp/log/file-tree.log'

function M.log(msg)
  if not M.enabled then
    return
  end

  local fp = assert(io.open(M.file_path, 'a'))
  local str = string.format('[%-6s%s] %s\n', 'LOG', os.date(), msg)
  fp:write(str)
  fp:close()
end

return M
