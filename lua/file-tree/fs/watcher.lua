local uv = vim.loop
local create = require('file-tree.utils.create')

local log = require('file-tree.logger').log

local interval = 1000

local Listener = {}

function Listener:create(path, handler)
  self = create(self, { path = path })

  log('[polling] start: ' .. path)
  self.poll = uv.new_fs_poll()
  self.poll:start(path, interval, function()
    -- log('change in: ' .. path)
    handler(path)
  end)

  return self
end

function Listener:dispose()
  log('[polling] stop:  ' .. self.path)
  self.poll:stop()
  self.poll = nil
end

local M = {}

function M:create(delegate, opts)
  self = create(self, {
    listeners = {},
  })

  self:add(opts.dir)

  self.on_change = function(typ)
    vim.schedule(function()
      delegate:update(typ)
    end)
  end

  return self
end

--------------------------------------------------------------------------------
-- new API

function M:has(path)
  return self.listeners[path] ~= nil
end

function M:add(path)
  assert(path ~= nil, 'path must be set')
  if not self:has(path) then
    self.listeners[path] = Listener:create(path, function()
      self.on_change('file')
    end)
  end
end

function M:remove(path)
  assert(path ~= nil, 'path must be set')
  if self:has(path) then
    self.listeners[path]:dispose()
    self.listeners[path] = nil
  end
end

function M:set(paths)
  for path in pairs(self.listeners) do
    if not vim.tbl_contains(paths, path) then
      self:remove(path)
    end
  end
  for i, path in ipairs(paths) do
    self:add(path)
  end
end

function M:reset()
  for _, listener in pairs(self.listeners) do
    listener:dispose()
  end
  self.listeners = {}
end

function M:dispose()
  self:reset()
end

return M
