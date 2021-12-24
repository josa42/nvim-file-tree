local uv = vim.loop
local create = require('file-tree.utils.create')
local g = require('file-tree.api.global')

local M = {}

function M:create(delegate, opts)
  self = create(self)

  self.w_files = uv.new_fs_poll()
  self.w_git = uv.new_fs_poll()

  self.on_change = function(typ)
    vim.schedule(function()
      delegate:update(typ)
    end)
  end

  self.interval = opts.interval or 1000
  self.dir = opts.dir
  self.git_root = opts.git_root

  self.dispose_autocmd = g.on('DirChanged', '*', function()
    self.on_change('dir')
  end)

  self:start()

  return self
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
