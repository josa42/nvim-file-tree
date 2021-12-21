local M = {}

M.handler = {}

local cmdTpl = 'lua require("jg.file-tree.fn").handler[%s]()'

function M.wrap(fn)
  table.insert(M.handler, fn)

  local dispose = function()
    -- TODO dispose
  end

  return cmdTpl:format(#M.handler), dispose
end

return M
