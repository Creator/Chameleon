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

  for opt, arg in (run.require 'posix').getopt('hvFA:O:C', ...) do
    if opt == false and #arg ~= 0 then
      table.insert(args, arg)
    elseif opt == 'F' then isfi = true
    elseif opt == 'h' then (run.require 'info').usage('hash', 'calculate secure hashing algorithm 256 sum', '-F <file[file]...>/ <string[string]...>', {
      h = 'print help',
      v = 'print version',
      F = 'toggle file mode',
      A = 'specify hashing algorithm.',
      O = 'write to file',
      C = 'check that everything is OK',
    }) return
    elseif opt == 'v' then print('sha256 version 1') return
    elseif opt == 'A' then algo = arg
    elseif opt == 'O' then outp = arg
    elseif opt == 'C' then

      local printFancy = (run.require 'info').print
      printFancy({
        {txtCol = colors.green, text = '->'},
        {text = ' Checking algorithm '},
        {txtCol = colors.blue, text = 'sha256'}
      })
      local sharesults = {}

      for i = 1, 5 do
        print('\t\t-> Test: ' .. i)
        print('\t\t\t-> Generating ' .. 20*i .. ' chars of random data.')

        local data = ('xyxy'):randomize():rep(20*i)

        local p1, p2;
        p1 = hash.sha256(data)
        print('\t\t\t-> First pass hash: ' .. p1)
        p2 = hash.sha256(data)
        print('\t\t\t-> Second pass hash: ' .. p2)

        print('\t-> ' .. (p1 == p2 and 'OK' or 'Failed to verify sha256 workingness'))
        table.insert(sharesults, p1 == p2)
      end
      local shaoks, shafails = 0, 0;

      for i = 1, #sharesults do
        if sharesults[i] == true then shaoks = shaoks + 1
        else shafails = shafails + 1 end
      end

      printFancy({
        {txtCol = colors.green, text = '->'},
        {text = ' Checking algorithm '},
        {txtCol = colors.blue, text = 'crc32'}
      })

      local crcresults = {}

      for i = 1, 5 do
        print('\t\t-> Test: ' .. i)
        print('\t\t\t-> Generating ' .. 20*i .. ' chars of random data.')

        local data = ('xyxy'):randomize():rep(20*i)

        local p1, p2;
        p1 = hash.crc32(data)
        print('\t\t\t-> First pass hash: ' .. p1)
        p2 = hash.crc32(data)
        print('\t\t\t-> Second pass hash: ' .. p2)

        print('\t-> ' .. (p1 == p2 and 'OK' or 'Failed to verify sha256 workingness'))
        table.insert(crcresults, p1 == p2)
      end
      local crcoks, crcfails = 0, 0;

      for i = 1, #crcresults do
        if crcresults[i] == true then crcoks = crcoks + 1
        else crcfails = crcfails + 1 end
      end

      printFancy({
        {txtCol = colors.green, text = '->'},
        {text = ' Checking algorithm '},
        {txtCol = colors.blue, text = 'crc32'}
      })

      local fcsresults = {}

      for i = 1, 5 do
        print('\t\t-> Test: ' .. i)
        print('\t\t\t-> Generating ' .. 20*i .. ' chars of random data.')

        local data = ('xyxy'):randomize():rep(20*i)

        local p1, p2;
        p1 = hash.fcs16(data)
        print('\t\t\t-> First pass hash: ' .. p1)
        p2 = hash.fcs16(data)
        print('\t\t\t-> Second pass hash: ' .. p2)

        print('\t-> ' .. (p1 == p2 and 'OK' or 'Failed to verify fcs15 workingness'))
        table.insert(fcsresults, p1 == p2)
      end

      local fcsoks, fcsfails = 0, 0;

      for i = 1, #fcsresults do
        if fcsresults[i] == true then fcsoks = fcsoks + 1
        else fcsfails = fcsfails + 1 end
      end

      printFancy({
        {txtCol = colors.green, text = '->'},
        {text = ' Checking algorithm '},
        {txtCol = colors.blue, text = 'message digest 5'}
      })

      local md5results = {}

      for i = 1, 5 do
        print('\t\t-> Test: ' .. i)
        print('\t\t\t-> Generating ' .. 20*i .. ' chars of random data.')

        local data = ('xyxy'):randomize():rep(20*i)

        local p1, p2;
        p1 = hash.md5(data)
        print('\t\t\t-> First pass hash: ' .. p1)
        p2 = hash.md5(data)
        print('\t\t\t-> Second pass hash: ' .. p2)

        print('\t-> ' .. (p1 == p2 and 'OK' or 'Failed to verify md5 workingness'))
        table.insert(md5results, p1 == p2)
      end

      local md5oks, md5fails = 0, 0;

      for i = 1, #md5results do
        if md5results[i] == true then md5oks = md5oks + 1
        else md5fails = md5fails + 1 end
      end

      print('Final results:')
      print('\t\t', shaoks + fcsoks + crcoks + md5oks .. ' OKs.')
      print('\t\t', shafails + fcsfails + crcfails + md5fails .. ' fails.')
      if shaoks + fcsoks + crcoks + md5oks == 20 and shafails + fcsfails + crcfails + md5fails == 0 then
        print('Everything\'s OK.')
      else
        print('Something went wrong!')
      end
      return
    end
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
        local data = x.readAll()
        print(shell.resolve(args[i]) == '/' and '/' or '/' .. shell.resolve(args[i]).. ': ' .. hash(data))

        if outp then
          local han = fs.open(shell.resolve(outp), fs.exists(shell.resolve(outp)) and 'a' or 'w')
          han.writeLine(algo .. ' hash of ' .. shell.resolve(args[i]) == '/' and '/' or '/' .. shell.resolve(args[i]).. ': ' .. hash(data))
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
      O = 'write to file',
      C = 'check that everything is OK',
    })
    return false
  end

  return true
end
