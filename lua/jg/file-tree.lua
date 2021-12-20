-- Source: https://github.com/josa42/nvim-filetree/blob/b0d980a03c10ad357c4959d783bf58e81c3d89e3/pkg/plugin.go

local ui = require('jg.file-tree.ui')
local buf = require('jg.file-tree.buf')

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

  vim.api.nvim_set_var(varIsOpen, false)
  vim.api.nvim_set_var(varIsOpening, false)
  vim.api.nvim_set_var(varTreeBuf, -1)

  -- tp.treeView = view.NewTreeView(files.NewFileProvider(api))

  vim.cmd('augroup jg.file-tree')
  vim.cmd('autocmd!')
  vim.cmd('autocmd WinEnter * call v:lua.require("jg.file-tree").onEnterSyncState()')
  vim.cmd('autocmd BufEnter * call v:lua.require("jg.file-tree").onLeaveCloseLastTree()')
  vim.cmd('autocmd WinLeave * call v:lua.require("jg.file-tree").onLeaveUnfocusTree()')
  vim.cmd('augroup END')
end

--------------------------------------------------------------------------------
-- open

function M.open()
  if vim.api.nvim_get_var(varIsOpening) or l.ignoreCurrentTab() then
    return
  end

  vim.api.nvim_set_var(varIsOpening, true)
  vim.api.nvim_set_var(varIsOpen, true)

  local b = l.getOrCreateBuffer()
  if not l.hasTreeBuffer() then
    l.attachTreeBuffer(b)
  end

  vim.api.nvim_set_var(varIsOpening, false)
end

function M.close()
  vim.api.nvim_set_var(varIsOpen, false)
  buf.close(l.getTreeBuffer())
end

function M.focus()
  if not l.treeBufferHasFocus() then
    local b = l.getTreeBuffer()
    if b > 0 then
      local t = vim.api.nvim_get_current_tabpage()

      local w = ui.findTabpageWindow(t, function(w)
        return vim.api.nvim_win_get_buf(w) == b
      end)

      if w > 0 then
        vim.api.nvim_set_current_win(w)
      end
    end
  end
end

function M.unfocus()
  if l.treeBufferHasFocus() then
    l.focusEditor()
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
    return buf.get_var(b, varIsTree)
  end)
end

function l.createTreeBuffer()
  vim.api.nvim_set_var(varIsOpening, true)

  vim.cmd('topleft vertical ' .. width .. ' new')
  local b = vim.api.nvim_get_current_buf()

  buf.set_var(b, varIsTree, true)
  buf.set_var(b, varHideLightline, true)
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
  if vim.api.nvim_get_var(varIsOpening) then
    return
  end

  if l.ignoreCurrentTab() then
    -- if b, found := p.getTreeBuffer(); found {
    -- 	b.Close()
    -- }
    return
  end

  if vim.api.nvim_get_var(varIsOpen) then
    local focus = l.treeBufferHasFocus()

    M.open()

    if not focus then
      M.unfocus()
    end
  else
    M.close()
  end
end

--------------------------------------------------------------------------------

function M.onLeaveCloseLastTree()
  if vim.api.nvim_get_var(varIsOpening) then
    return
  end

  if l.hasOnlyTreeBuffer() then
    local t = vim.api.nvim_get_current_tabpage()
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
      if #vim.api.nvim_list_wins() == 1 then
        vim.cmd('quit')
      else
        vim.api.nvim_win_close(w, true)
      end
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
  local b = vim.api.nvim_get_current_buf()
  if buf.get_var(b, varIsTree) then
    local t = vim.api.nvim_get_current_tabpage()

    local w = ui.findTabpageWindow(t, function(_, wb)
      return not buf.get_var(wb, varIsTree)
    end)

    if w > 0 then
      vim.api.nvim_set_current_win(w)
    end
  end
end

--------------------------------------------------------------------------------
-- utils

function l.ignoreCurrentTab()
  -- for _, w := range p.api.CurrentTab().Windows() {
  -- 	if expIsVimspector.MatchString(w.Buffer().Path()) {
  -- 		return true
  -- 	}
  -- }
  --
  return false
end

function l.treeBufferHasFocus()
  local b = vim.api.nvim_get_var(varTreeBuf)
  return b > 0 and b == vim.api.nvim_get_current_buf()
end

function l.focusEditor()
  local t = vim.api.nvim_get_current_tabpage()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
    local b = vim.api.nvim_win_get_buf(w)
    if not buf.get_var(b, varIsTree) then
      vim.api.nvim_set_current_win(w)
    end
  end
end

return M
