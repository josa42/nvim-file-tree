local M = {}

function M.wrap_pcall(fn)
  return function(...)
    local ok, result = pcall(fn, ...)
    if not ok then
      return nil
    end
    return result
  end
end

return M
