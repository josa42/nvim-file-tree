local actions = require('file-tree.actions')
local create = require('file-tree.utils.create')

local l = {}

local levelPrefix = '  '

local TreeView = {}

function TreeView:create(provider)
  return create(self, {
    provider = provider,
    lines = {},
  })
end

function TreeView:attach(renderer)
  self.renderer = renderer
end

function TreeView:wrap_action(action)
  local treeView = self

  return function()
    local c = vim.api.nvim_win_get_cursor(0)

    local item = treeView.lines[c[1]].item
    if item then
      action(item)
    end

    treeView.renderer:render()
  end
end

function TreeView:initialize(b)
  vim.api.nvim_create_autocmd('CursorMoved', {
    buffer = b,
    callback = function()
      local c = vim.api.nvim_win_get_cursor(0)
      if c[2] ~= 0 then
        vim.api.nvim_win_set_cursor(0, { c[1], 0 })
      end
    end,
  })

  local nop = function() end

  local nopKeyMaps = { 'i', 'a', 'v', 'V', '<C>', '<C-v>', '<C-0>', 'h', 'l', '<Left>', '<Right>', '0', '$', '^' }
  for _, key in ipairs(nopKeyMaps) do
    vim.keymap.set('', key, nop, { silent = true, noremap = true, buffer = b })
  end

  for key, fn in pairs(actions) do
    vim.keymap.set('n', key, self:wrap_action(fn), { silent = true, noremap = true, buffer = b })
  end
end

function TreeView:update()
  self.lines = l.get_visible_lines('', self.provider.root:children())

  local paths = {}
  for _, line in ipairs(self.lines) do
    if line.item.is_dir and line.item.is_open then
      table.insert(paths, line.item.path)
    end
  end

  self.provider:set_watch_paths(paths)
end

function l.get_visible_lines(prefix, items)
  local lines = {}

  for _, item in ipairs(items) do
    table.insert(lines, { item = item, prefix = prefix })
    if item.is_dir and item.is_open then
      for _, line in ipairs(l.get_visible_lines(prefix .. levelPrefix, item:children())) do
        table.insert(lines, line)
      end
    end
  end

  return lines
end

function TreeView:render_lines()
  local lines = {}

  for _, line in ipairs(self.lines) do
    table.insert(lines, line.item:render(line.prefix))
  end

  return lines
end

return TreeView
