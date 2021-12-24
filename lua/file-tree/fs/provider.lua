local g = require('file-tree.api.global')
local fs = require('file-tree.fs.fs')
local Item = require('file-tree.fs.item')
local watcher = require('file-tree.fs.watcher')
local status = require('file-tree.fs.status')
local run = require('file-tree.exec').run
local create = require('file-tree.utils.create')

local log = require('file-tree.logger').log

local Provider = {}

function Provider:create()
  self = create(self)

  local dir = vim.fn.getcwd()

  self.status = status:create(self)
  self.root = Item:create(self, dir)
  self.watcher = watcher:create(self, { dir = dir })

  self.dispose_autocmd = g.on('DirChanged', '*', function()
    self:update_dir(vim.fn.getcwd())
    self:update_git_root()
  end)

  self:update_dir(dir)
  self:update_git_root()

  return self
end

function Provider:update()
  -- log('provider -> update')
  self.status:update()

  -- TODO can this be handled more efficient?
  self:trigger_changed()
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
  log('update_dir: ' .. self.root.path .. ' => ' .. dir)
  if dir ~= self.root.path then
    self.watcher:add(dir)
    self.watcher:remove(self.root.path)
    self.root.path = dir
    self:trigger_changed()
  end
end

function Provider:update_git_root()
  self:get_git_root(self.root.path, function(git_root)
    -- log('update_git_root: ' .. git_root)

    local git_dir = git_root ~= nil and git_root .. '/.git' or nil
    if self.git_dir ~= git_dir then
      self.watcher:add(git_dir)
      if self.git_dir ~= nil then
        self.watcher:remove(self.git_dir)
      end

      self.git_dir = git_dir
      self.status:set_git_root(git_root)
    end
  end)
end

function Provider:get_git_root(dir, cb)
  run({ 'git', 'rev-parse', '--show-toplevel', cwd = dir }, function(_, out)
    cb(out ~= nil and out:gsub('%s+$', '') or nil)
  end)
end

return Provider
