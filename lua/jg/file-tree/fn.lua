local M = {}

M.handler = {}

local cmdTpl = 'lua require("jg.file-tree.fn").handler[%s]()'

function M.wrap(fn)
  assert(fn ~= nil, 'fn must be defined')

  table.insert(M.handler, fn)

  local idx = #M.handler
  local dispose = function()
    M.handler[idx] = nil
  end

  return cmdTpl:format(#M.handler), dispose
end

return M
