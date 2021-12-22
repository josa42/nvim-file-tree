local buf = require('jg.file-tree.api.buf')
local fn_wrap = require('jg.file-tree.api.fn').wrap
local actions = require('jg.file-tree.actions')

local l = {}

local levelPrefix = '  '

local TreeView = {}

function TreeView:create(provider)
  local o = {
    provider = provider,
    lines = {},
  }
  setmetatable(o, self)
  self.__index = self

  return o
end

function TreeView:attach(renderer)
  self.renderer = renderer
end

local mapCmdTpl = ':%s<cr>'

function TreeView:wrap_action(action)
  local treeView = self

  -- TODO handle disposing
  local cmd, _ = fn_wrap(function()
    local c = vim.api.nvim_win_get_cursor(0)

    local item = treeView.lines[c[1]].item
    if item then
      action(item)
    end

    treeView.renderer:render()
  end)

  return mapCmdTpl:format(cmd)
end

function TreeView:initialize(b)
  buf.on(b, 'CursorMoved', function()
    local c = vim.api.nvim_win_get_cursor(0)
    if c[2] ~= 0 then
      vim.api.nvim_win_set_cursor(0, { c[1], 0 })
    end
  end)
  --
  local nopKeyMaps = { 'i', 'a', 'v', 'V', '<C>', '<C-v>', '<C-0>', 'h', 'l', '<Left>', '<Right>', '0', '$', '^' }
  for _, k in ipairs(nopKeyMaps) do
    vim.api.nvim_buf_set_keymap(b, '', k, '<nop>', { silent = true })
  end

  for key, fn in pairs(actions) do
    vim.api.nvim_buf_set_keymap(b, 'n', key, self:wrap_action(fn), { silent = true })
  end
end

function TreeView:update()
  self.lines = l.get_visible_lines('', self.provider.root:children())
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
