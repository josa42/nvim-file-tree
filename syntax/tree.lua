vim.cmd.syn('match', 'TreeIcon', [[/\(^\(  \)*. \)\@<=[^ ]/]])
vim.cmd.syn('match', 'TreeDirIcon', [[/[󰉋󰝰▸▾•]/]], 'containedin=TreeIcon')
vim.cmd.syn('match', 'TreeFileIcon', [[/[󰈔•]/]], 'containedin=TreeIcon')

vim.cmd.syn('match', 'TreeName', [[/\(^\(  \)*. [󰉋󰝰󰈔▸▾•] \)\@<=.*$/]])

vim.cmd.syn('match', 'TreeDirName', [[/\(^\(  \)*. [󰉋󰝰▸▾•] \)\@<=.*$/]])
vim.cmd.syn('match', 'TreeFileName', [[/\(^\(  \)*. [󰈔•] \)\@<=.*$/]])

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
