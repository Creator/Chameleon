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

local info = (run.require 'libinfo')
local cron = (run.require 'libcron')

function main()
  local minute = os.startTimer(20)
  local hour = os.startTimer(200)
  local day = os.startTimer(2000)
  local year = os.startTimer(20000)


  while true do
    local data = {coroutine.yield()}
    if data[1] == 'timer' then
      if data[2] == minute then
        minute = os.startTimer(20)
        cron.onMinute()
      elseif data[2] == hour then
        hour = os.startTimer(200)
        cron.onHour()
      elseif data[2] == day then
        day = os.startTimer(2000)
        cron.onDay()
      elseif data[2] == year then
        year = os.startTimer(20000)
        cron.onYear()
      end
    end
  end
end
