local buf = require('jg.file-tree.buf')

local M = {}

M.Renderer = {}

function M.Renderer:create(b, view)
  local o = { buf = b, view = view }
  setmetatable(o, self)
  self.__index = self
  return o
end

function M.Renderer:render()
  if self.view == nil or self.buf == nil then
    error('Renderer:render(): View must not be nil')
    return
  end

  self.view:update()

  local lines = self.view:lines()
  local linesHash = vim.fn.json_encode(lines)

  if self.linesHash ~= linesHash then
    buf.set_option(self.buf, 'modifiable', true)
    buf.set_option(self.buf, 'readonly', false)
    local c = vim.api.nvim_win_get_cursor(0)

    buf.set_lines(self.buf, self.view:lines())

    buf.set_option(self.buf, 'modifiable', false)
    buf.set_option(self.buf, 'readonly', true)
    vim.api.nvim_win_set_cursor(0, c)

    self.linesHash = linesHash
  end
end

function M.attach(b, view)
  local r = M.Renderer:create(b, view)

  view:attach(r)
  view:initialize(b)

  r:render()

  return r
end

return M
