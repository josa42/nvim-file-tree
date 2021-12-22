local fs = require('jg.file-tree.fs.fs')
local status = require('jg.file-tree.fs.status')
local g = require('jg.file-tree.api.global')

local Item = {}

local iconThemes = {
  nerdfont = { '', 'ﱮ', '' },
  default = { '▸', '▾', '•' },
}

local status_icons = {
  [status.Changed] = '◎',
  [status.Untracked] = '⦿',
  [status.Conflicted] = '◉',
}

function Item:create(provider, path)
  local o = {
    name = fs.basename(path),
    path = path,
    is_dir = fs.is_dir(path),
    is_open = false,
    children_cache = {},
    matchIgnore = nil,
    provider = provider,
  }
  setmetatable(o, self)
  self.__index = self

  return o
end

function Item:children()
  local names = fs.read_dir(self.path)
  local children = {}

  for _, name in ipairs(names) do
    local path = fs.join(self.path, name)

    if not self.provider:is_ignored(path) then
      local found = false
      for _, child in ipairs(self.children_cache) do
        if child.name == name then
          table.insert(children, child)
          found = true
          break
        end
      end

      if not found then
        table.insert(children, Item:create(self.provider, path))
      end
    end
  end

  table.sort(children, function(a, b)
    if a.is_dir == b.is_dir then
      return a.name < b.name
    end

    return a.is_dir
  end)

  self.children_cache = children

  return children
end

function Item:render(prefix)
  return table.concat({
    prefix,
    self:status_icon(),
    ' ',
    self:icon(),
    ' ',
    self.name,
    (self.is_dir and '/' or ''),
  })
end

function Item:open()
  self.is_open = true
end

function Item:close()
  self.is_open = false
end

function Item:toggle()
  self.is_open = not self.is_open
end

function Item:icon()
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

function Item:status_icon()
  local s = self.provider.status:get(self.path, self.is_dir)

  for key, icon in pairs(status_icons) do
    if key == s then
      return icon
    end
  end

  return ' '
end

return Item
