local g = require('jg.file-tree.global')
local fs = require('jg.file-tree.fs.fs')
local Item = require('jg.file-tree.fs.item')
local watcher = require('jg.file-tree.fs.watcher')
local status = require('jg.file-tree.fs.status')

local Provider = {}

function Provider:create()
  local o = {}

  setmetatable(o, self)
  self.__index = self

  local dir = vim.fn.getcwd()

  o.status = status:create(dir, o)
  o.root = Item:create(o, dir)

  o.watcher = watcher:create(function()
    o:update()
  end)

  return o
end

function Provider:update()
  local dir = vim.fn.getcwd()

  if self.root.path ~= dir then
    self.root.path = dir
    self.status:set_dir(dir)
  end

  self.status:update()
  self:trigger_changed()
end

function Provider:trigger_changed()
  if self.delegate ~= nil then
    self.delegate:render()
  end
end

function Provider:is_ignored(path)
  if fs.basename(path) == '.git' or self.status:get(path, false) == status.Ignored then
    return true
  end

  return false
end

return Provider
