-- Source: https://github.com/josa42/nvim-filetree/blob/b0d980a03c10ad357c4959d783bf58e81c3d89e3/pkg/plugin.go

local ui = require('jg.file-tree.ui')
local buf = require('jg.file-tree.buf')
local renderer = require('jg.file-tree.renderer')
local TreeView = require('jg.file-tree.view')
local FileProvider = require('jg.file-tree.fs.provider')

local M = {}
local l = {}

local buffer_name = 'פּ'
local var_is_tree = '__is-file-tree'
local var_hide_lightline = 'lightline_hidden'
local var_tree_buf = '__tree_buffer_id'
local var_is_open = '__file-tree_open'
local var_is_opening = '__file-tree_opening'
local width = 40

function M.setup()
  vim.api.nvim_set_var(var_is_open, false)
  vim.api.nvim_set_var(var_is_opening, false)
  vim.api.nvim_set_var(var_tree_buf, -1)

  vim.cmd('augroup jg.file-tree')
  vim.cmd('autocmd!')
  vim.cmd('autocmd WinEnter * call v:lua.require("jg.file-tree").on_enter_sync_state()')
  vim.cmd('autocmd BufEnter * call v:lua.require("jg.file-tree").on_leave_close_last_tree()')
  vim.cmd('autocmd WinLeave * call v:lua.require("jg.file-tree").on_leave_unfocus_tree()')
  vim.cmd('augroup END')
end

--------------------------------------------------------------------------------
-- open

function M.open()
  vim.api.nvim_set_var(var_is_opening, true)
  vim.api.nvim_set_var(var_is_open, true)

  local b = l.get_or_create_buffer()
  if not l.tab_has_tree_buffer() then
    l.tab_attach_tree_buffer(b)
  end

  vim.api.nvim_set_var(var_is_opening, false)
end

function M.close()
  vim.api.nvim_set_var(var_is_open, false)
  buf.close(l.get_tree_buffer())
end

function M.focus()
  if not l.tree_buffer_has_focus() then
    local b = l.get_tree_buffer()
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
  if l.tree_buffer_has_focus() then
    l.focus_editor()
  end
end

function M.toggle()
  if vim.api.nvim_get_var(var_is_open) then
    M.close()
  else
    M.open()
    M.focus()
  end
end

function M.toggle_focus()
  if l.tree_buffer_has_focus() then
    M.unfocus()
  elseif l.tab_has_tree_buffer() then
    M.focus()
  else
    M.open()
  end
end

function M.toggle_smart()
  if l.tree_buffer_has_focus() then
    M.close()
  elseif l.tab_has_tree_buffer() then
    M.focus()
  else
    M.open()
  end
end

--------------------------------------------------------------------------------

function l.get_or_create_buffer()
  local b = l.get_tree_buffer()
  if b ~= -1 then
    return b
  end

  return l.create_tree_buffer()
end

function l.get_tree_buffer()
  return ui.findBuffer(function(b)
    return buf.get_var(b, var_is_tree)
  end)
end

function l.create_tree_buffer()
  vim.api.nvim_set_var(var_is_opening, true)

  vim.cmd('topleft vertical ' .. width .. ' new')
  local b = vim.api.nvim_get_current_buf()

  buf.set_var(b, var_is_tree, true)
  buf.set_var(b, var_hide_lightline, true)
  vim.api.nvim_buf_set_option(b, 'filetype', 'tree')
  vim.api.nvim_buf_set_name(b, buffer_name)

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
    'buftype=nofile',
  }, ' '))

  vim.cmd('iabclear <buffer>')
  vim.cmd('set winhighlight=Normal:TreeNormal')
  --
  if M.tree_view == nil then
    M.provider = FileProvider:create()
    M.tree_view = TreeView:create(M.provider)
  end

  M.provider.delegate = renderer.attach(b, M.tree_view)

  vim.api.nvim_set_var(var_tree_buf, b)
  vim.api.nvim_set_var(var_is_opening, false)

  return b
end

function l.tab_has_tree_buffer()
  local t = vim.api.nvim_get_current_tabpage()
  local b = l.get_tree_buffer()

  return b > 0 and ui.tabpageHasBuffer(t, b)
end

function l.tab_attach_tree_buffer(b)
  vim.cmd('topleft vertical ' .. width .. ' new | buffer ' .. b)

  local w = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_option(w, 'winfixwidth', true)
end

--------------------------------------------------------------------------------
-- Sync open file tree across tabs

function M.on_enter_sync_state()
  if vim.api.nvim_get_var(var_is_opening) then
    return
  end

  if vim.api.nvim_get_var(var_is_open) then
    local focus = l.tree_buffer_has_focus()

    M.open()

    if not focus then
      M.unfocus()
    end
  else
    M.close()
  end
end

--------------------------------------------------------------------------------

function M.on_leave_close_last_tree()
  if vim.api.nvim_get_var(var_is_opening) then
    return
  end

  if l.has_only_tree_buffer() then
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

function l.has_only_tree_buffer()
  local t = vim.api.nvim_get_current_tabpage()
  local b = vim.api.nvim_get_var(var_tree_buf)

  return ui.tabpageHasBuffer(t, b) and #vim.api.nvim_tabpage_list_wins(t) == 1
end

--------------------------------------------------------------------------------

function M.on_leave_unfocus_tree()
  local b = vim.api.nvim_get_current_buf()
  if buf.get_var(b, var_is_tree) then
    local t = vim.api.nvim_get_current_tabpage()

    local w = ui.findTabpageWindow(t, function(_, wb)
      return not buf.get_var(wb, var_is_tree)
    end)

    if w > 0 then
      vim.api.nvim_set_current_win(w)
    end
  end
end

--------------------------------------------------------------------------------
-- utils

function l.tree_buffer_has_focus()
  local b = vim.api.nvim_get_var(var_tree_buf)
  return b > 0 and b == vim.api.nvim_get_current_buf()
end

function l.focus_editor()
  local t = vim.api.nvim_get_current_tabpage()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
    local b = vim.api.nvim_win_get_buf(w)
    if not buf.get_var(b, var_is_tree) then
      vim.api.nvim_set_current_win(w)
    end
  end
end

return M
