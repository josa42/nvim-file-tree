local fn = require('file-tree.api.fn')

local M = {}

M.get_var = fn.wrap_pcall(vim.api.nvim_get_var)
M.set_var = fn.wrap_pcall(vim.api.nvim_set_var)

M.get_option = fn.wrap_pcall(vim.api.nvim_get_option)
M.set_option = fn.wrap_pcall(vim.api.nvim_set_option)

return M
