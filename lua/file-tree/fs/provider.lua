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

  vim.api.nvim_create_autocmd('DirChanged', {
    callback = function()
      self:update_dir(vim.fn.getcwd())
      self:update_git_root()
    end,
  })

  vim.api.nvim_create_autocmd('FocusGained', {
    callback = function()
      self:update()
    end,
  })

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
  return fs.basename(path) == '.git' or self.status:get(path, false) == status.Ignored
end

function Provider:update_dir(dir)
  log('update_dir: ' .. self.root.path .. ' => ' .. dir)
  if dir ~= self.root.path then
    self.root.path = dir
    self:trigger_changed()
    self:update_watcher()
  end
end

function Provider:update_git_root()
  self:get_git_root(self.root.path, function(git_root)
    -- log('update_git_root: ' .. git_root)

    local git_dir = git_root ~= nil and git_root .. '/.git' or nil
    if self.git_dir ~= git_dir then
      self.git_dir = git_dir
      self.status:set_git_root(git_root)
      self:update_watcher()
    end
  end)
end

function Provider:get_git_root(dir, cb)
  run({ 'git', 'rev-parse', '--show-toplevel', cwd = dir }, function(_, out)
    cb(out ~= nil and out:gsub('%s+$', '') or nil)
  end)
end

function Provider:set_watch_paths(paths)
  self.watch_paths = paths
  self:update_watcher()
end

function Provider:update_watcher()
  local paths = vim.tbl_extend('keep', {}, self.watch_paths)
  table.insert(paths, self.root.path)
  if self.git_dir ~= nil then
    table.insert(paths, self.git_dir)
  end

  self.watcher:set(paths)
end

return Provider
