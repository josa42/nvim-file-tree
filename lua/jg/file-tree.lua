-- Source: https://github.com/josa42/nvim-filetree/blob/b0d980a03c10ad357c4959d783bf58e81c3d89e3/pkg/plugin.go

local ui = require('jg.file-tree.ui')

local M = {}
local l = {}

local bufferName = 'פּ'
local varIsTree = '__is-tree-buffer'
local varHideLightline = 'lightline_hidden'
local width = 40

function M.setup()
  print('setup: nvim-file-tree')
end

function M.open()
  local b = l.getOrCreateBuffer()
  if not l.hasTreeBuffer() then
    l.attachTreeBuffer(b)
  end
end

function l.getOrCreateBuffer()
  local b = l.getTreeBuffer()
  if b ~= -1 then
    return b
  end

  return l.createTreeBuffer()
end

function l.getTreeBuffer()
  return ui.findBuffer(function(b)
    return vim.api.nvim_buf_get_var(b, varIsTree)
  end)
end

function l.createTreeBuffer()
  -- p.api.Global.Vars.SetBool(GlobalVarIsTreeOpening, true)
  -- defer p.api.Global.Vars.SetBool(GlobalVarIsTreeOpening, false)

  vim.cmd('topleft vertical ' .. width .. ' new')
  local b = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_set_var(b, varIsTree, true)
  vim.api.nvim_buf_set_var(b, varHideLightline, true)
  vim.api.nvim_buf_set_option(b, 'filetype', 'tree')
  vim.api.nvim_buf_set_name(b, bufferName)

  --
  vim.cmd('setlocal ' .. table.concat({
    'cursorline',
    'foldcolumn=0',
    'nonumber',
    'foldmethod=manual',
    'nocursorcolumn',
    'nofoldenable',
    'nolist',
    'norelativenumber',
    'nospell',
    'nowrap',
    'signcolumn=no',
    'colorcolumn=',
  }, ' '))

  vim.cmd('iabclear <buffer>')
  vim.cmd('set winhighlight=Normal:TreeNormal')
  --
  -- p.api.Renderer.Attach(buffer, p.treeView)
  --
  -- p.api.Global.Vars.SetInt(GlobalVarTreeBufferID, buffer.ID())
  -- p.api.Global.Vars.SetBool(GlobalVarIsTreeOpening, false)

  return b
end

function l.hasTreeBuffer()
  local t = vim.api.nvim_get_current_tabpage()
  local b = l.getTreeBuffer()

  return b > 0 and ui.tabpageHasBuffer(t, b)
end

function l.attachTreeBuffer(b)
  -- p.api.Global.Vars.SetInt(GlobalVarTreeBufferID, b.ID())

  vim.cmd('topleft vertical ' .. width .. ' new | buffer ' .. b)

  local w = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_option(w, 'winfixwidth', true)
end

return M
