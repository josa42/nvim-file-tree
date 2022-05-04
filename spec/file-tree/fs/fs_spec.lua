local fs = require('file-tree.fs.fs')

describe('basename()', function()
  it('show get base name', function()
    assert(fs.basename('/foo/bar/test.txt') == 'test.txt')
  end)
end)

describe('join()', function()
  it('join a path', function()
    assert(fs.join('foo', 'bar', 'test.txt') == 'foo/bar/test.txt')
  end)
end)
