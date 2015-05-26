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
  local args = {}
  local isfi;

  local hash = (run.require 'hash').sha256

  for opt, arg in (run.require 'posix').getopt('hvF', ...) do
    if opt == false and #arg ~= 0 then
      table.insert(args, arg)
    elseif opt == 'F' then isfi = true
    elseif opt == 'h' then (run.require 'info').usage('sha', 'calculate secure hashing algorithm 256 sum', '-F <file[file]...>/ <string[string]...>', {
      h = 'print help',
      v = 'print version',
      F = 'toggle file mode'
    }) return
    elseif opt == 'v' then print('sha256 version 1') return end
  end


  if isfi then
    for i = 1, #args do
      if fs.exists(shell.resolve(args[i])) and not fs.isDir(shell.resolve(args[i])) then
        local x = fs.open(shell.resolve(args[i]), 'r')
        print(shell.resolve(args[i]) == '/' and '/' or '/' .. shell.resolve(args[i]).. ': ' .. hash(x.readAll()))
        x.close()
      elseif fs.isDir(shell.resolve(args[i])) then
        print(shell.resolve(args[i]) == '/' and '/' or '/' .. shell.resolve(args[i]) .. ': is a directory.')
      elseif not fs.exists(shell.resolve(args[i])) then
        print(shell.resolve(args[i]) == '/' and '/' or '/' .. shell.resolve(args[i])  .. ': does not exist.')
      end
    end
  else
    for i = 1, #args do
      print((args[i]) .. ': ' .. hash(args[i]))
    end
  end

  return true
end
