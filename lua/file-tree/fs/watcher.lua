local uv = vim.loop
local g = require('file-tree.api.global')

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

function M:create(on_change, opts)
  opts = opts or {}

  local o = {}

  setmetatable(o, self)
  self.__index = self

  o.dir = vim.fn.getcwd()
  o.on_change = on_change
  o.interval = opts.interval or 1000

  o.dispose_autocmd = g.on('DirChanged', '*', function()
    o:set_path(vim.fn.getcwd())
  end)

  o:start()

  return o
end

function M:set_path(dir)
  if self.dir ~= dir then
    self.dir = dir
    self:start()
  end
end

function M:start()
  if self.dispose_polling ~= nil then
    self.dispose_polling()
  end

  local on_change = self.on_change
  local handler = function(typ)
    return function()
      vim.schedule(function()
        on_change(typ)
      end)
    end
  end

  local w_files = uv.new_fs_poll()
  w_files:start(self.dir, self.interval, handler('file'))

  -- TODO find correct git root
  local w_git = uv.new_fs_poll()
  w_git:start(self.dir .. '/.git', self.interval, handler('git'))

  self.dispose_polling = function()
    w_files:stop()
    w_git:stop()
  end

  self.on_change('init')
end

function M:dispose()
  if self.dispose ~= nil then
    self.dispose()
  end
  if self.dispose_autocmd ~= nil then
    self.dispose_autocmd()
  end
end

return M
