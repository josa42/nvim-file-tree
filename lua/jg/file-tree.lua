-- Source: https://github.com/josa42/nvim-filetree/blob/b0d980a03c10ad357c4959d783bf58e81c3d89e3/pkg/plugin.go

local ui = require('jg.file-tree.ui')

local M = {}
local l = {}

local bufferName = 'פּ'
local varIsTree = '__is-file-tree'
local varHideLightline = 'lightline_hidden'
local varTreeBuf = 'tree_buffer_id'
local varIsOpen = '__file-tree_open'
local varIsOpening = '__file-tree_opening'
local width = 40

function M.setup()
  print('setup: nvim-file-tree')

  vim.api.nvim_set_var(varIsOpening, false)
  vim.api.nvim_set_var(varTreeBuf, -1)

  -- tp.treeView = view.NewTreeView(files.NewFileProvider(api))

  vim.cmd('augroup jg.file-tree')
  vim.cmd('autocmd!')
  vim.cmd('autocmd BufWinEnter,WinEnter * call v:lua.require("jg.file-tree").onEnterSyncState()')
  vim.cmd('autocmd BufEnter * call v:lua.require("jg.file-tree").onLeaveCloseLastTree()')
  vim.cmd('autocmd WinLeave * call v:lua.require("jg.file-tree").onLeaveUnfocusTree()')
  vim.cmd('augroup END')
end

--------------------------------------------------------------------------------
-- open

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
  vim.api.nvim_set_var(varIsOpening, true)

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
  vim.api.nvim_set_var(varTreeBuf, b)
  vim.api.nvim_set_var(varIsOpening, false)

  return b
end

function l.hasTreeBuffer()
  local t = vim.api.nvim_get_current_tabpage()
  local b = l.getTreeBuffer()

  return b > 0 and ui.tabpageHasBuffer(t, b)
end

function l.attachTreeBuffer(b)
  -- TODO this is not needed is it?
  vim.api.nvim_set_var(varTreeBuf, b)

  vim.cmd('topleft vertical ' .. width .. ' new | buffer ' .. b)

  local w = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_option(w, 'winfixwidth', true)
end

--------------------------------------------------------------------------------
-- Sync open file tree across tabs

function M.onEnterSyncState()
  -- 	if p.api.Global.Vars.Bool(GlobalVarIsTreeOpening) {
  -- 		return
  -- 	}
  --
  -- 	if p.ignoreCurrentTab() {
  -- 		if b, found := p.getTreeBuffer(); found {
  -- 			b.Close()
  -- 		}
  --
  -- 		return
  -- 	}
  --
  -- 	if p.api.Global.Vars.Bool(GlobalVarIsTreeOpen) {
  -- 		focus := p.treeBufferHasFocus()
  -- 		p.Open()
  --
  -- 		if !focus {
  -- 			p.Unfocus()
  -- 		}
  -- 	} else {
  -- 		p.Close()
  -- 	}
end

--------------------------------------------------------------------------------

function M.onLeaveCloseLastTree()
  if vim.api.nvim_get_var(varIsOpening) then
    return
  end
  --
  if l.hasOnlyTreeBuffer() then
    local t = vim.api.nvim_get_current_tabpage()
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
      vim.api.nvim_win_close(w, true)
    end
  end
end

function l.hasOnlyTreeBuffer()
  local t = vim.api.nvim_get_current_tabpage()
  local b = vim.api.nvim_get_var(varTreeBuf)

  return ui.tabpageHasBuffer(t, b) and #vim.api.nvim_tabpage_list_wins(t) == 1
end

--------------------------------------------------------------------------------

function M.onLeaveUnfocusTree()
  -- b := p.api.CurrentBuffer()
  --
  -- if b.Vars.Bool(BufferVarIsTree) {
  -- 	tab := p.api.CurrentTab()
  -- 	window, _ := tab.FindWindow(func(window *neovim.Window) bool {
  -- 		return !window.Buffer().Vars.Bool(BufferVarIsTree)
  -- 	})
  --
  -- 	window.Focus()
  -- }
end

return M
