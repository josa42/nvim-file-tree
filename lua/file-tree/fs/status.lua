local run = require('file-tree.exec').run

local status = {}
local l = {}

status.Normal = 'normal'
status.Ignored = 'ignored'
status.Changed = 'changed'
status.Untracked = 'untracked'
status.Conflicted = 'conflicted'

--  [AMD]   = not updated
-- M[ MD]   = updated in index
-- A[ MD]   = added to index
-- R[ MD]   = renamed in index
-- C[ MD]   = copied in index
-- [MARC]   = index and work tree matches
-- [ MARC]M = work tree changed since index
-- [ D]R    = renamed in work tree
-- [ D]C    = copied in work tree
local expChanged = vim.regex('\\v^( [AMD]|M[ MD]|A[ MD]|R[ MD]|C[ MD]|[MARC] |[ MARC]M|[ D]R|[ D]C)')
--
-- [ MARC]D = deleted in work tree
-- D        =deleted from index
local expDeleted = vim.regex('\\v^([ MARC]D|D )')

-- AU = unmerged, added by us
-- UD = unmerged, deleted by them
-- UA = unmerged, added by them
-- DU = unmerged, deleted by us
-- AA = unmerged, both added
-- UU = unmerged, both modified
local expConflicted = vim.regex('\\v^(DD|AU|UD|UA|DU|AA|UU)')

-- untracked
local expUntracked = vim.regex('\\v^\\?\\?')

-- ignored
local expIgnored = vim.regex('\\v^\\!\\!')

function status:create(delegate)
  local o = {}

  setmetatable(o, self)
  self.__index = self

  o.files = {}
  o.delegate = delegate

  return o
end

function status:set_git_root(git_root)
  if git_root ~= nil then
    git_root = l.trim_right(git_root, '/')
  end
  if self.git_root ~= git_root then
    self.git_root = git_root
    self:update()
  end
end

function status:update()
  if self.git_root == nil then
    self.files = {}
    return
  end

  local git_root = self.git_root
  run(
    { 'git', 'status', '--porcelain', '--ignored', env = { 'GIT_OPTIONAL_LOCKS=0' }, cwd = self.git_root },
    function(_, out)
      vim.schedule(function()
        if self.git_root ~= git_root then
          return
        end

        local files = {}
        for _, line in ipairs(vim.fn.split(out, '\n')) do
          local path = self.git_root .. '/' .. l.trim_right(line:sub(4), '/')
          files[path] = l.get_status(line)
        end

        if vim.fn.json_encode(self.files) ~= vim.fn.json_encode(files) then
          self.files = files
          if self.delegate ~= nil then
            self.delegate:trigger_changed()
          end
        end
      end)
    end
  )
end

function status:get(path, is_dir)
  path = l.trim_right(path, '/')

  if is_dir then
    for _, s in ipairs({ status.Conflicted, status.Changed, status.Untracked }) do
      if self:dirContains(path, s) then
        return s
      end
    end
  elseif self.files[path] ~= nil then
    return self.files[path]
  end

  return status.Normal
end

function status:dirContains(path, fileStatus)
  path = l.trim_right(path, '/') .. '/'

  for p, fs in pairs(self.files or {}) do
    if fs == fileStatus and l.has_prefix(p, path) then
      return true
    end
  end

  return false
end

function l.get_status(line)
  if expConflicted:match_str(line) ~= nil then
    return status.Conflicted
  elseif expUntracked:match_str(line) ~= nil then
    return status.Untracked
  elseif expIgnored:match_str(line) ~= nil then
    return status.Ignored
  elseif expChanged:match_str(line) ~= nil then
    return status.Changed
  end

  return status.Normal
end

function l.trim_right(str, char)
  while str:sub(-1) == char do
    str = str:sub(1, #str - 1)
  end

  return str
end

function l.has_prefix(str, prefix)
  return str:sub(1, #prefix) == prefix
end

function l.strip_prefix(str, prefix)
  if l.has_prefix(str, prefix) then
    return str:sub(-1 * (#str - #prefix))
  end
  return str
end

return status
