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

  local hash = (run.require 'hash')
  local algo;

  local outp;

  for opt, arg in (run.require 'posix').getopt('hvFA:O:', ...) do
    if opt == false and #arg ~= 0 then
      table.insert(args, arg)
    elseif opt == 'F' then isfi = true
    elseif opt == 'h' then (run.require 'info').usage('hash', 'calculate secure hashing algorithm 256 sum', '-F <file[file]...>/ <string[string]...>', {
      h = 'print help',
      v = 'print version',
      F = 'toggle file mode',
      A = 'specify hashing algorithm.',
      O = 'write to file'
    }) return
    elseif opt == 'v' then print('sha256 version 1') return
    elseif opt == 'A' then algo = arg
    elseif opt == 'O' then outp = arg end
  end

  if not algo then
    hash = hash.sha256
    algo = 'sha256'
  else
    hash = hash[algo] or hash.sha256
    if hash == (run.require 'hash').sha256 then
      algo = 'sha256'
      printError('Unknown algorithm ' .. algo)
    end
  end

  if outp then
    fs.delete(outp)
  end
  if isfi then
    for i = 1, #args do
      if fs.exists(shell.resolve(args[i])) and not fs.isDir(shell.resolve(args[i])) then
        local x = fs.open(shell.resolve(args[i]), 'r')
        print(shell.resolve(args[i]) == '/' and '/' or '/' .. shell.resolve(args[i]).. ': ' .. hash(x.readAll()))

        if outp then
          local han = fs.open(shell.resolve(outp), fs.exists(shell.resolve(outp)) and 'a' or 'w')
          han.writeLine(algo .. ' hash of ' .. shell.resolve(args[i]) == '/' and '/' or '/' .. shell.resolve(args[i]).. ': ' .. hash(x.readAll()))
          han.close()
        end
        x.close()
      elseif fs.isDir(shell.resolve(args[i])) then
        print(shell.resolve(args[i]) == '/' and '/' or '/' .. shell.resolve(args[i]) .. ': is a directory.')
      elseif not fs.exists(shell.resolve(args[i])) then
        print(shell.resolve(args[i]) == '/' and '/' or '/' .. shell.resolve(args[i])  .. ': does not exist.')
      end
    end
  elseif #args ~= 0 then
    for i = 1, #args do
      print(args[i] .. ': ' .. hash(args[i]))
      if outp then
        local han = fs.open(shell.resolve(outp), fs.exists(shell.resolve(outp)) and 'a' or 'w')
        han.writeLine(args[1] .. ': ' .. hash(args[i]))
        han.close()
      end
    end
  else
    (run.require 'info').usage('hash', 'calculate secure hashing algorithm 256 sum', '-F <file[file]...>/ <string[string]...>', {
      h = 'print help',
      v = 'print version',
      F = 'toggle file mode',
      A = 'specify hashing algorithm.',
      O = 'write to file'
    })
    return false
  end

  return true
end
