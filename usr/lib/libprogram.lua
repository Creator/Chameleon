--[[
The MIT License (MIT)

Copyright (c) 2014-2015 the TARDIX team


Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
local program = {}

local program_mt = {}

function program_mt:add(func)
  if not self.proc then
    self.proc = (getfenv(2).process.this and getfenv(2).process.this or process.main):spawnSubprocess(getRandomTardixID())
  end

  self.proc:spawnThread(func, getRandomTardixID())
end

function program_mt:start()
  if not self.proc then error('You need to add some functions first!',2) end
  while true do
    local data = {coroutine.yield()}
    if data[1] == 'terminate' then
      break
    end

    self.proc:update(unpack(data))
  end
end

function program.start(func1, ...)
  local _prog = {}
  setmetatable(_prog, program_mt)

  _prog:add(func1)
  for k, v in pairs({...})
    _prog:add(v)
  end

  _prog:start()
  return _prog
end

return program
