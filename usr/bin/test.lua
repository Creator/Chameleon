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
  local expr, inv;

  for opt, arg in (run.require 'posix').getopt('hvrn:z:d:e:', ...) do
    if opt == false and not expr then expr = (arg ~= nil)
    elseif opt == 'h' then
      (run.require 'info').usage('test', 'evaluate an expression', '<flag> <opt>', {
        h = 'print this help',
        v = 'print version',
        r = 'invert output (similar to !<expr> in C)',
        n = 'lenght of string is not zero',
        z = 'lenght of string is zero',
        d = 'file is a directory',
        e = 'file exists'
      }) return
    elseif opt == 'n' then expr = (#arg ~= 0) break
    elseif opt == 'z' then expr = (#arg == 0) break
    elseif opt == 'r' then inv = true
    elseif opt == 'd' then expr = (fs.isDir(arg))
    elseif opt == 'e' then expr = (fs.exists(arg))
    elseif opt == 'v' then print('test version 1') end
  end

  if inv then
    return (expr == true and false or true)
  else
    return expr
  end
end
