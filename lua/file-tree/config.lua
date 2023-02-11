local status = require('file-tree.fs.status')
local g = require('file-tree.api.global')

local M = {}

M.tree_signs = g.get_var('nerdfont') and {
  file = '󰈔',
  dir = '󰉋',
  dir_open = '󰝰',
} or {
  file = '•',
  dir = '▸',
  dir_open = '▾',
}

M.status_signs = {
  [status.Changed] = '◎',
  [status.Untracked] = '⦿',
  [status.Conflicted] = '◉',
}

return M
