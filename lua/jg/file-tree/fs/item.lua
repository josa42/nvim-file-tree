local fs = require('jg.file-tree.fs.fs')

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
    isOpen = false, -- bool
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
    -- 		if ok && !i.provider.isIgnored(i.path) && i.provider.fileStatus.get(i.path, false) != FileStatusIgnored {
    if not self.provider.isIgnored(child.path) then
      -- 			filtered = append(filtered, c)
      table.insert(filtered, child)
    end
  end

  return filtered
end

-- function FileItem:String() string {
-- 	icon := i.icon()
-- 	if i.is_dir {
-- 		if i.isOpen {
-- 			return fmt.Sprintf("%c %s/", icon, i.name)
-- 		} else {
-- 			return fmt.Sprintf("%c %s/", icon, i.name)
-- 		}
-- 	}
--
-- 	return fmt.Sprintf("%c %s", icon, i.name)
-- }
--
-- // Openable Interface
--
-- function FileItem:IsOpenable() bool {
-- 	return i.is_dir
-- }
--
-- function FileItem:IsOpen() bool {
-- 	return i.isOpen
-- }
--
-- function FileItem:Open() {
-- 	i.isOpen = true
-- }
--
-- function FileItem:Close() {
-- 	i.isOpen = false
-- }
--
-- function FileItem:icon() rune {
-- 	icons := iconThemes["default"]
-- 	if i.provider.api.Global.Vars.Bool("nerdfont") {
-- 		icons = iconThemes["nerdfont"]
-- 	}
-- 	if i.is_dir {
-- 		if !i.isOpen {
-- 			return icons[0]
--
-- 		} else {
-- 			return icons[1]
-- 		}
-- 	}
--
-- 	return icons[2]
-- }
--
-- // statusable interface
--
-- function FileItem:Status() rune {
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
-- }
return FileItem
