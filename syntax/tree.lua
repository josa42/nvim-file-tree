local signs = require('file-tree.config').tree_signs
local file = signs.file
local dir = ('%s%s'):format(signs.dir, signs.dir_open)
local entry = ('%s%s'):format(dir, file)

vim.cmd.syn('match', 'TreeIcon', [[/\(^\(  \)*. \)\@<=[^ ]/]])
vim.cmd.syn('match', 'TreeDirIcon', ([[/[%s]/]]):format(dir), 'containedin=TreeIcon')
vim.cmd.syn('match', 'TreeFileIcon', ([[/[%s]/]]):format(file), 'containedin=TreeIcon')

vim.cmd.syn('match', 'TreeName', ([[/\(^\(  \)*. [%s] \)\@<=.*$/]]):format(entry))

vim.cmd.syn('match', 'TreeDirName', ([[/\(^\(  \)*. [%s] \)\@<=.*$/]]):format(dir))
vim.cmd.syn('match', 'TreeFileName', ([[/\(^\(  \)*. [%s] \)\@<=.*$/]]):format(file))

vim.cmd.syn('match', 'TreeDirSlash', [[#/#]], 'containedin=TreeName,TreeDirName')

vim.cmd.syn('match', 'TreeFileExt', [[/\.\([a-z]\{2,4\}\)$/]], 'containedin=TreeName,TreeFileName')

vim.cmd.syn('match', 'TreeStatus', [[/\(^\(  \)*\)\@<=[^ ]\([^ ] \)\@=/]])
vim.cmd.syn('match', 'TreeStatusChanged', [[/\(^\(  \)*\)\@<=◎/  containedin=TreeStatus]])
vim.cmd.syn('match', 'TreeStatusAdded', [[/\(^\(  \)*\)\@<=⦿/  containedin=TreeStatus]])
vim.cmd.syn('match', 'TreeStatusConcflicted', [[/\(^\(  \)*\)\@<=◉/  containedin=TreeStatus]])

-- Default theme
vim.cmd.hi('default', 'link', 'TreeNormal', 'Normal')
vim.cmd.hi('default', 'link', 'TreeFileIcon', 'TreeNormal')
vim.cmd.hi('default', 'link', 'TreeDirIcon', 'Directory')
vim.cmd.hi('default', 'link', 'TreeDirSlash', 'Comment')
vim.cmd.hi('default', 'link', 'TreeDirName', 'Directory')

vim.cmd.hi('default', 'link', 'TreeStatus', 'Comment')
vim.cmd.hi('default', 'link', 'TreeStatusChanged', 'TreeStatus')
vim.cmd.hi('default', 'link', 'TreeStatusAdded', 'TreeStatus')
vim.cmd.hi('default', 'link', 'TreeStatusConcflicted', 'Error')
