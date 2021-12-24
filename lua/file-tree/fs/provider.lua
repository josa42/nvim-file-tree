local g = require('file-tree.api.global')
local fs = require('file-tree.fs.fs')
local Item = require('file-tree.fs.item')
local watcher = require('file-tree.fs.watcher')
local status = require('file-tree.fs.status')
local run = require('file-tree.exec').run

local Provider = {}

function Provider:create()
  local o = {}

  setmetatable(o, self)
  self.__index = self

  local dir = vim.fn.getcwd()

  o.status = status:create(dir, o)
  o.root = Item:create(o, dir)
  o.watcher = watcher:create(o, { dir = dir })

  o:update_git_root()

  return o
end

function Provider:update()
  local dir = vim.fn.getcwd()
  if self.root.path ~= dir then
    self:update_dir(dir)
    self:update_git_root()
  end

  if self.git_root ~= nil then
    self.status:update(self.git_root)
  end
end

function Provider:trigger_changed()
  if self.renderer ~= nil then
    self.renderer:render()
  end
end

function Provider:is_ignored(path)
  if fs.basename(path) == '.git' or self.status:get(path, false) == status.Ignored then
    return true
  end

  return false
end

function Provider:update_dir(dir)
  self.root.path = dir
  self.watcher:set_path(dir)
  self:trigger_changed()
end

function Provider:update_git_root()
  self:get_git_root(self.root.path, function(git_root)
    if self.git_root ~= git_root then
      self.git_root = git_root
      self.watcher:set_git_root(git_root)
      self.status:update(git_root)
    end
  end)
end

function Provider:get_git_root(dir, cb)
  run({ 'git', 'rev-parse', '--show-toplevel', cwd = dir }, function(_, out)
    cb(out ~= nil and out:gsub('%s+$', '') or nil)
  end)
end

return Provider
