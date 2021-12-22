local uv = vim.loop

-- TODO remove plenary dependency
local void = require('plenary.async.async').void
local scheduler = require('plenary.async.util').scheduler

local M = {}

function M.watch(dir, fn, opts)
  opts = opts or {}

  local w = uv.new_fs_poll()
  w:start(dir, opts.interval or 1000, function()
    vim.schedule(fn)
  end)

  return function()
    w:stop()
  end
end

return M
