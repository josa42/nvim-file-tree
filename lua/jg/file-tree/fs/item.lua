local fs = require('jg.file-tree.fs.fs')
local g = require('jg.file-tree.global')

local FileItem = {}

-- // Interface Assertions
-- var _ view.TreeItem = (*FileItem)(nil)
-- var _ view.Openable = (*FileItem)(nil)
-- var _ view.Statusable = (*FileItem)(nil)

local iconThemes = {
  nerdfont = { '', 'ﱮ', '' },
  default = { '▸', '▾', '•' },
}

function FileItem:create(provider, path)
  local o = {
    name = fs.basename(path), -- string
    path = path, -- string
    is_dir = fs.is_dir(path), -- bool
    is_open = true, -- bool
    childItems = {}, -- []view.TreeItem
    matchIgnore = nil, -- *func(string) bool
    provider = provider, -- *FileProvider
  }
  setmetatable(o, self)
  self.__index = self

  return o
end

function FileItem:createChild(name)
  return FileItem:create(self.provider, fs.join(self.path, name))
end

function FileItem:children()
  local names = fs.read_dir(self.path)
  local children = {}

  for _, name in ipairs(names) do
    local found = false
    for _, child in ipairs(self.childItems) do
      if child.name == name then
        table.insert(children, child)
        found = true
        break
      end
    end
    if not found then
      table.insert(children, self:createChild(name))
    end
  end

  table.sort(children, function(a, b)
    if a.is_dir == b.is_dir then
      return a.name < b.name
    end

    return a.is_dir
  end)

  self.childItems = children

  local filtered = {}

  for _, child in ipairs(self.childItems) do
    -- TODO What's provider file status? Simplify it
    -- i.provider.fileStatus.get(i.path, false) != FileStatusIgnored
    if not self.provider:is_ignored(child.path) then
      table.insert(filtered, child)
    end
  end

  return filtered
end

function FileItem:render(prefix)
  local status = ' '
  -- 	if i, ok := l.item.(Statusable); ok {
  -- 		status = i.Status()
  -- 	}

  local icon = self:icon()

  if self.is_dir then
    return prefix .. status .. icon .. ' ' .. self.name .. '/'
  end
  return prefix .. status .. icon .. ' ' .. self.name
end
--
-- // Openable Interface
--
-- function FileItem:IsOpenable() bool {
-- 	return i.is_dir
-- }
--
-- function FileItem:IsOpen() bool {
-- 	return i.is_open
-- }
--
-- function FileItem:Open() {
-- 	i.is_open = true
-- }
--
-- function FileItem:Close() {
-- 	i.is_open = false
-- }
--
function FileItem:icon()
  local icons = iconThemes['default']
  if g.get_var('nerdfont') then
    icons = iconThemes['nerdfont']
  end

  if self.is_dir then
    if not self.is_open then
      return icons[1]
    else
      return icons[2]
    end
  end
  --
  return icons[3]
end
--
-- // statusable interface
--
function FileItem:status()
  -- 	switch i.provider.fileStatus.get(i.path, i.is_dir) {
  -- 	case FileStatusChanged:
  -- 		return view.ItemStatusChanged
  --
  -- 	case FileStatusUntracked:
  -- 		return view.ItemStatusAdded
  --
  -- 	case FileStatusConflicted:
  -- 		return view.ItemStatusConflicted
  --
  -- 	default:
  -- 		return ' '
  -- 	}
  return ' '
end

return FileItem
