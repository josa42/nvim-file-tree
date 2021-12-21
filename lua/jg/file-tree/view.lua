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
-- type line struct {
-- 	prefix string
-- 	item   TreeItem
-- }
--
-- func (l *line) String() string {
-- 	status := ' '
-- 	if i, ok := l.item.(Statusable); ok {
-- 		status = i.Status()
-- 	}
--
-- 	return fmt.Sprintf("%s%s %s", l.prefix, string(status), l.item.String())
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

function TreeView:rerender()
  self.renderer:render()
end

function TreeView:initialize(b)
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
  -- 	nopKeyMaps := []string{"i", "a", "v", "V", "<C>", "<C-v>", "<C-0>", "h", "l", "<Left>", "<Right>", "0", "$", "^"}
  --
  -- 	for _, m := range nopKeyMaps {
  -- 		b.KeyMaps.Disable(neovim.ModeAll, m)
  -- 	}
  --
  -- 	if p, ok := t.provider.(ActionableTree); ok {
  -- 		for _, a := range p.Actions() {
  -- 			func(a TreeAction) {
  -- 				fn := api.Handler.Create(func() {
  -- 					win := api.CurrentWindow()
  -- 					cursor := win.Cursor()
  -- 					idx := cursor.Y() - 1
  --
  -- 					if idx >= 0 && idx < len(t.lines) {
  -- 						a.Handler(t.lines[idx].item)
  -- 						t.renderer.ShouldRender()
  -- 					}
  -- 				})
  -- 				t.disposables.Add(fn)
  -- 				b.KeyMaps.Set(neovim.ModeNormal, a.Keys, fmt.Sprintf(`:silent call %s<CR>`, fn))
  -- 			}(a)
  -- 		}
  -- 	}
  --
  -- 	if p, ok := t.provider.(Changable); ok {
  -- 		p.Listen(func() {
  -- 			t.renderer.ShouldRender()
  -- 		})
  -- 	}
end

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
    -- TODO proper line rendering
    table.insert(lines, prefix .. item.name)
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

  return self.lineData
end

return TreeView
