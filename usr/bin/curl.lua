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

function main(...)
  local url;
  local out;

  for opt, arg in (run.require 'posix').getopt('hvO:', ...) do
    if opt == false then
      url = arg
    elseif opt == 'h' then
      (run.require 'info').usage('curl', 'cat url', '<url> [-O file]', {
        h = 'print this usage information',
        v = 'print version information',
        O = 'write the downloaded data to a file.'
      })
    elseif opt == 'v' then
      print('cat url version 1')
    elseif opt == 'O' then
      out = arg
    end
  end

  if out and url then
    local file = fs.open(out, 'w')
    local han = http.get(url)

    if not han then
      printError('failed to get ' .. url)
      return
    end

    file.writeLine(han.readAll())
    file.close()
  elseif url then
    local han = http.get(url)

    if not han then
      printError('failed to get ' .. url)
      return
    end
    print(han.readAll())
  else
    (run.require 'info').usage('curl', 'cat url', '<url> [-O file]', {
      h = 'print this usage information',
      v = 'print version information',
      O = 'write the downloaded data to a file.'
    })
  end
end
