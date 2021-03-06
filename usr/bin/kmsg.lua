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

local function sC(col) if term.isColor and term.isColor() then term.setTextColor(col) end end


local function printm(ind)
  if not ind then
    for i = #kmsg.backup, 1, -1 do
      local v = kmsg.backup[i]
      sC(colors.blue)
      write('[' .. i .. '/')
      sC(colors.red)
      write(v.time .. '/')
      sC(colors.green)
      write(v.sender .. '] ')

      sC(colors.white)
      print(v.text)
    end
  else
    for i = ind, 1, -1 do
      local v = kmsg.backup[i]
      sC(colors.blue)
      write('[' .. i .. '/')
      sC(colors.red)
      write(v.time .. '/')
      sC(colors.green)
      write(v.sender .. '] ')

      sC(colors.white)
      print(v.text)
    end
  end
end

function main(...)
  local amt;

  for opt, arg in (run.require 'posix').getopt('hvc:', ...) do
    if opt == 'c' then amt = arg
    elseif opt == 'h' then (run.require 'info').usage('kmsg', 'kernel messaging system', '', {
      h = 'print this help information',
      v = 'print version information',
      c = 'amount of lines to read.'
    }) return
    elseif opt == 'v' then print('kmsg version 2') return end
  end

  if amt then
    printm(amt)
  else
    printm()
  end
  return true

end
