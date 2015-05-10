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
local libt = {}

local function fore(tab, fun)
  for k, v in pairs(tab) do
    fun(k, v)
  end
end

libt.syscretval = 0

function table.from(tab, sta)
  local buf = {}
  for i = sta, #tab do
    buf[#buf] = tab[i]
  end
  return buf
end

fore(_G, function(key, val)
  libt[key] = function(...)
    spawn(function()
      local timer = os.startTimer(10)
      while true do
        local data = {coroutine.yield()}
        if data[1] == 'syscall_return' then
          libt.syscretval = unpack(table.from(data, 1))
        elseif data[1] == 'syscall_failure' and data[2] == 'unknown' then
          printError('unknown system call ' .. data[3])
        elseif data[1] == 'timer' and data[2] == timer then
          break
        end
      end
    end)
    os.queueEvent('syscall', 'sys_'.. key, ...)
    return libt.syscretval
  end
end)


return libt
