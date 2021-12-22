local uv = vim.loop

local M = {}
local l = {}

--
-- Usage:
--
-- run({ 'ls', '-l' }, function(_, out)
--   print(out)
-- end)
--
function M.run(opts, on_done)
  local cmd, args = '', {}

  for i, s in ipairs(opts) do
    if i == 1 then
      cmd = s
    else
      table.insert(args, s)
    end
  end

  assert(#cmd > 0, 'must set a command')

  local stdout = {}
  local stderr = {}

  local stdout_pipe, stdout_start, stdout_close = l.pipe_read(stdout)
  local stderr_pipe, stderr_start, stderr_close = l.pipe_read(stderr)
  local stdin_pipe, stdin_start, stdin_close = l.pipe_write(opts.stdin)

  local handle, pid = uv.spawn(cmd, {
    args = args,
    stdio = { stdin_pipe, stdout_pipe, stderr_pipe },
    cwd = opts.cwd,
  }, function(code)
    stdout_close()
    stderr_close()
    stdin_close()

    on_done(code, l.concat(stdout), l.concat(stderr))
  end)

  if not handle then
    error('Failed to spawn process: ' .. vim.inspect(opts))
  end

  stdout_start()
  stderr_start()
  stdin_start()

  return { pid = pid }
end

function l.pipe_read(data)
  local p = uv.new_pipe(false)
  local reading = false

  local start = function()
    if not data then
      error('no data passed to pipe')
    end

    reading = true
    p:read_start(function(_, chunk)
      data[#data + 1] = chunk
    end)

    return data
  end

  local close = function()
    if reading then
      p:read_stop()
    end
    if not p:is_closing() then
      p:close()
    end
  end

  return p, start, close
end

function l.pipe_write(stdin)
  if stdin == nil then
    return nil, function() end, function() end
  end

  local p = uv.new_pipe(false)

  local start = function()
    if type(stdin) == 'table' then
      local stdin_len = #stdin
      for i, v in ipairs(stdin) do
        p:write(v)
        if i ~= stdin_len then
          p:write('\n')
        else
          p:write('\n', function()
            p:close()
          end)
        end
      end
    elseif stdin then
      p:write(stdin, function()
        p:close()
      end)
    end
  end

  local close = function()
    if not p:is_closing() then
      p:close()
    end
  end

  return p, start, close
end

function l.concat(data)
  return #data > 0 and table.concat(data) or nil
end

return M
