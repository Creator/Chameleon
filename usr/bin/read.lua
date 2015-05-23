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

local function tac(arg2)
  local file = fs.open(arg2, 'r')
  local data = file.readAll():split('\n')
  file.close()
  for i = #data, 0, -1 do
    print(data[i])
  end
end

local function cat(arg1)
  local file = fs.open(arg1, 'r')
  if file then
    print(file.readAll())
    file.close()
  else
    printError(('%s: failed to open %s.'):format(_FILE or 'read', arg1))
  end
end


function main(arg1, arg2)
  if arg2 and arg2 == 'reverse' then
    tac(fs.combine(shell.dir(), arg1))
  elseif arg1 then
    cat(fs.combine(shell.dir(), arg1))
  else
    print(("usage:\n\t%s <file> reverse"):format(_FILE or 'read'))
  end
end
