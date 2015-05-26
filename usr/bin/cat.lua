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

local function read(reverse, files, lines)
  if files and type(files) == 'table' and #files >= 1 then
    for i = 1, #files do
      local x = fs.open(shell.resolve(files[i]), 'r')
      local e;
      if x and x.readAll and string.split then
        e = string.split(x.readAll(), '\n')
        x.close()
      else
        printError('failed to open file ' .. files[i])
      end

      if reverse then
        for j = #e, 1, -1 do
          print(e[j])
        end
      else
        for j = 1, #e do
          print(e[j])
        end
      end
    end
  else
    while true do
      local data = io.read()
      if data == 'exit' then
        return
      else
        print(data)
      end
    end
  end
end


local function usag()
  (run.require 'info').usage('cat', 'read a file (or in reverse)', '<file1[file2...]>', {
    h = 'print this help information',
    v = 'print version information',
    r = 'read the file in reverse'
  })
end

local function vers()
  print(('cat version 1'))
end

-- Hello.
function main(...)

  local files = {}
  local rever = false

  for opt, arg in (run.require 'posix').getopt('hvr', ...) do
    if opt == 'h' then usag() return
    elseif opt == 'v' then vers() return
    elseif opt == false then table.insert(files, arg)
    elseif opt == 'r' then rever = true end
  end

  read(rever, files)
  return true
end
