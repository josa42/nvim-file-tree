local run = require('jg.file-tree.exec').run

local M = {}
local l = {}

function l.regexpr(expr_str)
  local expr = vim.regex(expr_str)
  return function(str)
    return expr:match_str(str) ~= nil
  end
end

M.Normal = 'normal'
M.Ignored = 'ignored'
M.Changed = 'changed'
M.Untracked = 'untracked'
M.Conflicted = 'conflicted'

--  [AMD]   = not updated
-- M[ MD]   = updated in index
-- A[ MD]   = added to index
-- R[ MD]   = renamed in index
-- C[ MD]   = copied in index
-- [MARC]   = index and work tree matches
-- [ MARC]M = work tree changed since index
-- [ D]R    = renamed in work tree
-- [ D]C    = copied in work tree
local expChanged = l.regexpr('\\v^( [AMD]|M[ MD]|A[ MD]|R[ MD]|C[ MD]|[MARC] |[ MARC]M|[ D]R|[ D]C)')
--
-- [ MARC]D = deleted in work tree
-- D        =deleted from index
local expDeleted = l.regexpr('\\v^([ MARC]D|D )')

-- AU = unmerged, added by us
-- UD = unmerged, deleted by them
-- UA = unmerged, added by them
-- DU = unmerged, deleted by us
-- AA = unmerged, both added
-- UU = unmerged, both modified
local expConflicted = l.regexpr('\\v^(DD|AU|UD|UA|DU|AA|UU)')

-- untracked
local expUntracked = l.regexpr('\\v^\\?\\?')

-- ignored
local expIgnored = l.regexpr('\\v^\\!\\!')

-- local expStatusLine = regexpr('^(..) (.*)$')

function M:create(dir, delegate)
  local o = {}

  assert(dir ~= nil, 'dir must be set')

  setmetatable(o, self)
  self.__index = self

  o.files = {}
  o.delegate = delegate

  o:set_dir(dir)

  return o
end

function M:set_dir(dir)
  self.dir = l.trim_right(dir, '/')
end

function M:update()
  local s = self
  run({ 'git', 'status', '--short', '--ignored' }, function(code, out)
    vim.schedule(function()
      local files = {}
      for _, line in ipairs(vim.fn.split(out, '\n')) do
        files[l.trim_right(line:sub(4), '/')] = l.get_status(line)
      end

      if vim.fn.json_encode(s.files) ~= vim.fn.json_encode(files) then
        s.files = files
        if s.delegate ~= nil then
          self.delegate:trigger_changed()
        end
      end
    end)
  end)
end

function M:get(path, is_dir)
  path = l.trim_right(path, '/')
  path = l.strip_prefix(path, self.dir .. '/')

  if is_dir then
    for _, s in ipairs({ M.Conflicted, M.Changed, M.Untracked }) do
      if self:dirContains(path, s) then
        return s
      end
    end
  elseif self.files[path] ~= nil then
    return self.files[path]
  end

  return M.Normal
end

function M:dirContains(path, fileStatus)
  path = l.trim_right(path, '/') .. '/'

  for p, fs in pairs(self.files or {}) do
    if fs == fileStatus and l.has_prefix(p, path) then
      return true
    end
  end

  return false
end

function l.get_status(line)
  if expConflicted(line) then
    return M.Conflicted
  end

  if expUntracked(line) then
    return M.Untracked
  end

  if expIgnored(line) then
    return M.Ignored
  end

  if expChanged(line) then
    return M.Changed
  end
  --
  -- if m != "  " {
  -- 	log.Printf("default: '%s'", m)
  -- }
  return M.Normal
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

return M
