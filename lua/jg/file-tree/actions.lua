local buf = require('jg.file-tree.buf')

local function findWindow(path)
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local b = vim.api.nvim_win_get_buf(w)
    local wp = vim.fn.expand('#' .. b .. ':p')

    if wp == path then
      return w
    end
  end

  return -1
end

local function open(cmd, item)
  require('jg.file-tree').unfocus()
  vim.cmd(cmd .. ' ' .. item.path)
end

local function select(item)
  require('jg.file-tree').unfocus()

  local w = findWindow(item.path)
  if w > 0 then
    vim.api.nvim_set_current_win(w)
  elseif buf.is_empty(0) then
    open('edit', item)
  else
    open('tabedit', item)
  end
end

local actions = {
  ['<CR>'] = function(item)
    if item.is_dir then
      item:toggle()
    else
      select(item)
    end
  end,
  ['<2-LeftMouse>'] = function(item)
    if not item.is_dir then
      select(item)
    end
  end,
  ['<LeftRelease>'] = function(item)
    if item.is_dir then
      item:toggle()
    end
  end,
  ['o'] = function(item)
    if not item.is_dir then
      open('edit', item)
    end
  end,
  ['e'] = function(item)
    if not item.is_dir then
      open('edit', item)
    end
  end,
  ['<left>'] = function(item)
    if item.is_dir then
      item:close()
    end
  end,
  ['<right>'] = function(item)
    if item.is_dir then
      item:open()
    else
      open('edit', item)
      require('jg.file-tree').focus()
    end
  end,
  ['t'] = function(item)
    if not item.is_dir then
      open('tabedit', item)
    end
  end,
  ['v'] = function(item)
    if not item.is_dir then
      open('vsplit', item)
    end
  end,
  ['s'] = function(item)
    if not item.is_dir then
      open('split', item)
    end
  end,
  ['<ESC>'] = function()
    require('jg.file-tree').unfocus()
  end,
}

return actions
