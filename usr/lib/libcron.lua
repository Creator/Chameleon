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

local tasks = (function(file)
  if fs.exists(file) then
    local x = fs.open(file, 'r')
    local ret = textutils.unserialize(x.readAll())
    x.close()

    local ret_really = {}

    if ret['chains'] then
      for k, v in pairs(ret['chains']) do
        local f = fs.open(fs.combine('/usr/etc/cron.d/tabs/', v), 'r')
        local t = textutils.unserialize(x.readAll())
        if t['tasks'] then
          for e, d in pairs(t['tasks']) do
            ret_really[#ret_really + 1] = d
          end
        end
      end
    end

    if ret['tasks'] then
      for e, d in pairs(ret['tasks']) do
        ret_really[#ret_really + 1] = d
      end
    end

    local actually_ret = {}

    for k, v in pairs(ret_really) do
      if actually_ret[v.time or 'minute'] then
        table.insert(actually_ret[v.time or 'minute'], v.run)
      else
        actually_ret[v.time or 'minute'] = {v.run}
      end
    end

    return actually_ret
  else
    return {}
  end
end)('/usr/etc/cron.d/tab')

function onMinute()
  if tasks['minute'] then
    for k, v in pairs(tasks['minute']) do
      run.exec(unpack(v))
    end
  end
end

function onHour()
  if tasks['hour'] then
    for k, v in pairs(tasks['hour']) do
      run.exec(unpack(v))
    end
  end
end

function onDay()
  if tasks['day'] then
    for k, v in pairs(tasks['day']) do
      run.exec(unpack(v))
    end
  end
end
function onYear()
  if tasks['year'] then
    for k, v in pairs(tasks['year']) do
      run.exec(unpack(v))
    end
  end
end
