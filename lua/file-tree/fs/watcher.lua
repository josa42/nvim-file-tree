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

function M:create(delegate, opts)
  opts = opts or {}

  local o = {}

  setmetatable(o, self)
  self.__index = self

  o.w_files = uv.new_fs_poll()
  o.w_git = uv.new_fs_poll()

  o.on_change = function(typ)
    vim.schedule(function()
      delegate:update(typ)
    end)
  end

  o.interval = opts.interval or 1000
  o.dir = opts.dir
  o.git_root = opts.git_root

  o.dispose_autocmd = g.on('DirChanged', '*', function()
    o.on_change('dir')
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

function M:set_git_root(git_root)
  if self.git_root ~= git_root then
    self.git_root = git_root
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
      on_change(typ)
    end
  end

  if self.dir ~= nil then
    self.w_files:start(self.dir, self.interval, handler('file'))
  end

  if self.git_root ~= nil then
    self.w_git:start(self.git_root .. '/.git', self.interval, handler('git'))
  end

  self.dispose_polling = function()
    self.w_files:stop()
    self.w_git:stop()
  end
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
