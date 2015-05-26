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


local printFancy = (run.require 'libinfo').print;


local function printh()
  (run.require 'info').usage('pkgtool', 'package management tool', '<file1[file2...]>', {
    h = 'print this help information',
    v = 'print version information',
    I = 'install a package',
    R = 'remove a package',
    ['B/M/P'] = 'build a package for installation'
  })
  return true

end

local function versio()
  print(('pkgtool version 1'))
  return true

end

local function build(file)
  printFancy({
    {txtCol = colors.green, text = '::'},
    {text = ' Building package '},
    {txtCol = colors.blue, text = file}
  })
  local f = fs.open(file, 'r')
  file = textutils.unserialize(f.readAll())
  f.close()

  local ret = {}
  if file.files then
    for i = 1, #file.files do
      printFancy({
        {txtCol = colors.green, text = '\t-> '},
        {text = 'Generating file '},
        {txtCol = colors.blue, text = file.files[i].path}
      });
      local data = http.get(file.files[i].url).readAll()


      local libhash = (run.require 'hash')
      if file.files[i].sha256 and (not file.files[i].sha256 == libhash.sha256(data)) then
        printError('failed to download ' .. file.files[i].url)
      elseif file.files[i].crc32 and (not file.files[i].crc32 == libhash.crc32(data)) then
        printError('failed to download ' .. file.files[i].url)
      elseif file.files[i].fcs16 and (not file.files[i].fcs16 == libhash.fcs16(data)) then
        printError('failed to download ' .. file.files[i].url)
      end

      table.insert(ret,{
        ['data'] = data,
        ['meta'] = {
          ['size'] = #data,
          ['path'] = file.files[i].path
        }
      })
    end
  else
    printError('Malformed package description file.')
  end
  printFancy({
    {txtCol = colors.green, text = '\t-> '},
    {text = 'Writing file '},
    {txtCol = colors.blue, text = file.target or file .. '.lar'}
  });

  (run.require 'lar').write(file.target or file .. '.lar', ret)
  return true
end

local function remove(file, targ)
  printFancy({
    {txtCol = colors.green, text = '::'},
    {text = ' Removing package '},
    {txtCol = colors.blue, text = file}
  });
  if fs.exists(file) then
    (run.require 'lar').remlar(targ, file)
    if fs.exists(fs.combine('/var/pkgtool.cache/', file)) then
      fs.delete(fs.combine('/var/pkgtool.cache/', file))
    end
  elseif fs.exists(fs.combine('/var/pkgtool.cache/', file)) then
    (run.require 'lar').remlar(targ, fs.combine('/var/pkgtool.cache', file))
    fs.delete(fs.combine('/var/pkgtool.cache/', file))
  else
    printError('unknown package ' .. file)
  end
  return true
end

local function install(file, targ)
  printFancy({
    {txtCol = colors.green, text = ':: '},
    {text = 'Installing package '},
    {txtCol = colors.blue, text = file}
  });
  if not fs.isDir('/var/pkgtool.cache') then
    fs.makeDir('/var/pkgtool.cache')
  end

  if not fs.exists(fs.combine('/var/pkgtool.cache/', file)) then
    fs.copy(file, fs.combine('/var/pkgtool.cache/', file));
  end

  (run.require 'lar').unlar(targ, file)
  printFancy({
    {txtCol = colors.green, text = ':: '},
    {text = 'Installation successful.'},
  });  print('\tThe package file was moved into the cache.')
  io.write('\tWould you like to remove the source? [y/N]')
  local inp = read()

  if inp:lower() == 'y' then
    fs.delete(file)
  end
  return true
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
    elseif opt == 'R' then op = remove
      target = arg; break
    elseif opt == 'h' then op = printh break
    elseif opt == 'v' then op = versio break
    elseif opt == '?' then printError('Missing required argument.') return end
  end
  local targ = '/usr/local'
  if env then
    if env.PKGTOOL_TARGET then
      targ = env.PKGTOOL_TARGET
    end
  end
  if op then
    return op(target and shell.resolve(target) or 'no target required', targ)
  else
    printh()
  end
end
