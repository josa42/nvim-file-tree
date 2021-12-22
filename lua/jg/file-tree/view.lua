local buf = require('jg.file-tree.buf')
local fn_wrap = require('jg.file-tree.fn').wrap
local actions = require('jg.file-tree.actions')

local l = {}

-- package view
--
-- import (
-- 	"fmt"
--
-- 	"github.com/josa42/go-neovim"
-- 	"github.com/josa42/go-neovim/disposables"
-- )
--
-- const (
-- 	ItemStatusChanged    = '◎'
-- 	ItemStatusAdded      = '⦿'
-- 	ItemStatusConflicted = '◉'
-- )

local levelPrefix = '  '
--
-- type TreeProvider interface {
-- 	FileType() string
-- 	Root() TreeItem
-- }
--
-- type TreeItem interface {
-- 	String() string
-- 	Children() []TreeItem
-- }
--
-- type Openable interface {
-- 	IsOpenable() bool
-- 	IsOpen() bool
-- 	Open()
-- 	Close()
-- }
--
-- type Statusable interface {
-- 	Status() rune
-- }
--
-- type TreeAction struct {
-- 	Mode    string
-- 	Keys    string
-- 	Handler func(TreeItem)
-- }
--
-- type ActionableTree interface {
-- 	Actions() []TreeAction
-- }
--
-- type Changable interface {
-- 	Listen(func())
-- 	Unlisten()
-- }
--
-- // Interface Assertions
-- var _ neovim.View = (*TreeView)(nil)
-- var _ neovim.Initializable = (*TreeView)(nil)
-- var _ disposables.Disposable = (*TreeView)(nil)
--

local TreeView = {}

-- type TreeView struct {
-- 	renderer    neovim.ViewRenderer
-- 	provider    TreeProvider
-- 	lines       []line
-- 	disposables *disposables.Collection
-- }

function TreeView:create(provider)
  local o = {
    -- 	renderer    neovim.ViewRenderer
    provider = provider,
    lineData = {},
    -- 	disposables *disposables.Collection
  }
  setmetatable(o, self)
  self.__index = self

  provider.delegate = o

  return o
end

-- func NewTreeView(provider TreeProvider) *TreeView {
-- 	return &TreeView{
-- 		provider:    provider,
-- 		disposables: disposables.NewCollection(),
-- 	}
-- }

-- func (t *TreeView) FileType() string {
-- 	return t.provider.FileType()
-- }

function TreeView:attach(renderer)
  self.renderer = renderer
end

function TreeView:render()
  self.renderer:render()
end

local mapCmdTpl = ':%s<cr>'

function TreeView:wrap_action(action)
  local treeView = self

  -- TODO handle disposing
  local cmd, _ = fn_wrap(function()
    local c = vim.api.nvim_win_get_cursor(0)

    local item = treeView.lineData[c[1]].item
    if item then
      action(item)
    end

    treeView:render()
  end)

  return mapCmdTpl:format(cmd)
end

function TreeView:initialize(b)
  buf.on(b, 'CursorMoved', function()
    local c = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_win_set_cursor(0, { c[1], 0 })
    vim.cmd('normal! <C-c>')
    vim.cmd('set nohlsearch')
  end)
  --
  -- 	b.On(neovim.EventCursorMoved, func() {
  -- 		w := api.CurrentWindow()
  -- 		y := w.Cursor().Y()
  -- 		w.SetCursor(neovim.Cursor{y, 0})
  -- 		api.Execute("normal! <C-c>")
  -- 		api.Execute("set nohlsearch")
  --
  -- 	})
  --
  local nopKeyMaps = { 'i', 'a', 'v', 'V', '<C>', '<C-v>', '<C-0>', 'h', 'l', '<Left>', '<Right>', '0', '$', '^' }
  for _, k in ipairs(nopKeyMaps) do
    vim.api.nvim_buf_set_keymap(b, '', k, '<nop>', { silent = true })
  end

  -- local treeView = self

  -- -- TODO handle disposing
  -- local cmd = fn_wrap(function()
  --   local c = vim.api.nvim_win_get_cursor(0)
  --
  --   local item = treeView.lineData[c[1]].item
  --   if item.is_dir then
  --     item.is_open = not item.is_open
  --   end
  --
  --   treeView:render()
  -- end)

  for key, fn in pairs(actions) do
    vim.api.nvim_buf_set_keymap(b, 'n', key, self:wrap_action(fn), { silent = true })
  end

  -- 	if p, ok := t.provider.(Changable); ok {
  -- 		p.Listen(func() {
  -- 			t.renderer.ShouldRender()
  -- 		})
  -- 	}
end

-- func (p *FileProvider) handleAction(i *FileItem, action string) {
-- 	switch action {
-- 	case actions.Activate:
-- 		if i.isDir {
-- 			i.is_open = !i.is_open
-- 		} else {
-- 			opener.Activate(p.api, i.path)
-- 		}
--
-- 	case actions.ToggleDir:
-- 		if i.isDir {
-- 			i.is_open = !i.is_open
-- 		}
--
-- 	case actions.ActivateFile:
-- 		if !i.isDir {
-- 			opener.Activate(p.api, i.path)
-- 		}
--
-- 	case actions.Open:
-- 		opener.Open(p.api, i.path)
--
-- 	case actions.OpenTab:
-- 		opener.OpenTab(p.api, i.path)
--
-- 	case actions.OpenHorizontalSplit:
-- 		opener.OpenHoricontalSplit(p.api, i.path)
--
-- 	case actions.OpenVerticalSplit:
-- 		opener.OpenVerticalSplit(p.api, i.path)
--
-- 	case actions.Unfocus:
-- 		opener.FocusEditor(p.api)
--
-- 	case actions.Help:
-- 		p.api.Out.Print("?: Help - (o)pen - (e)dit - (t)ab - (s)plit - (v)ertical split - ESC unfocus")
-- 	}
-- }

-- func (t *TreeView) Dispose() {
-- 	if p, ok := t.provider.(Changable); ok {
-- 		p.Unlisten()
-- 	}
-- 	t.disposables.Dispose()
-- 	t.disposables = disposables.NewCollection()
-- }

function TreeView:update()
  -- 	if p, ok := t.provider.(neovim.Updatable); ok {
  -- 		p.Update()
  -- 	}
  --
  self.lineData = l.renderVisibleLines('', self.provider:root():children())
end

function l.renderVisibleLines(prefix, items)
  local lines = {}

  for _, item in ipairs(items) do
    table.insert(lines, { item = item, prefix = prefix })
    if l.shouldRenderChildren(item) then
      for _, line in ipairs(l.renderVisibleLines(prefix .. levelPrefix, item:children())) do
        table.insert(lines, line)
      end
    end
  end

  return lines
end

function l.shouldRenderChildren(item)
  return item.is_dir and item.is_open
end

function TreeView:lines()
  -- local lines = {}
  --
  -- for _, l := range t.lines {
  -- 	lines = append(lines, l.String())
  -- }

  local lines = {}
  for _, l in ipairs(self.lineData) do
    table.insert(lines, l.item:render(l.prefix))
  end

  return lines
end

return TreeView
