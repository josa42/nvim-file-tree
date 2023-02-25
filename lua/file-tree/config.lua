local status = require('file-tree.fs.status')

local M = {}

M.tree_signs = vim.g.nerdfont and {
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
