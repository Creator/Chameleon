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



local function printh()
  print('pkgtool - package management tool.\n'..
    '\tusage:\n'..
    '\tpkgtool [-h|-v|-B/M/P|-I] <file1[file2, ...]>\n'..
    '\t\t-h: print this help\n'..
    '\t\t-v: print the vesrion\n'..
    '\t\t-B or -M or -P: build a package\n'..
    '\t\t-I: install a package\n'..
    '\t\t-R: remove a package'
  )
end

local function versio()
  print(('pkgtool version 1'))
end

local function build(file)
  local f = fs.open(file, 'r')
  file = textutils.unserialize(f.readAll())
  f.close()

  local ret = {}
  if file.files then
    for i = 1, #file.files do
      local data = http.get(files[i].url)

      table.insert(ret,{
        ['data'] = data,
        ['meta'] = {
          ['size'] = #data,
          ['path'] = files[i].path
        }
      })
    end
  else
    printError('Malformed package description file.')
  end

  (run.require 'lar').write(file.target and file.target or file .. '.lar', ret)

end

local function remove(file)
  (run.require 'lar').remlar('/usr/local', file)
end

local function install(file)
  (run.require 'lar').unlar('/usr/local', file)
end

function main(...)
  local op, target;
  for opt, arg in (run.require 'posix').getopt('B:M:P:I:R:hv', ...) do
    if opt == 'B' then op = build
      target = arg break
    elseif opt == 'M' then op = build
      target = arg break
    elseif opt == 'P' then op = build
      target = arg ; break
    elseif opt == 'I' then op = install
      target = arg; break
    elseif opt == 'R' then op = remove break
    elseif opt == 'h' then op = printh break
    elseif opt == 'v' then op = versio break
    elseif opt == '?' then printError('Missing required argument.') return end
  end

  if op then
    op(target and shell.resolve(target) or 'no target required')
  else
    printh()
  end
end
