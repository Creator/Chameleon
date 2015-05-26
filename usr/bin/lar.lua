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

local function listAll(_path, _files)
  local path = _path or ""
  local files = _files or {}
  if #path > 1 then table.insert(files, path) end
  for _, file in ipairs(fs.list(path)) do
    local path = fs.combine(path, file)
    if fs.isDir(path) then
      listAll(path, files)
    else
      table.insert(files, path)
    end
  end
  return files
end

function main(...)
  local verb, comp, extr, file, dir, size = nil, nil, nil, nil, nil, size

  for opt, arg in (run.require 'posix').getopt('hsvxcf:d:', ...) do
    if opt == 'h' then
      (run.require 'info').usage('lar', 'lua archiver', '<flag> <dir>', {
        h = 'print help',
        v = 'print version',
        c = 'compress',
        f = 'target/input file',
        x = 'extract.'
      }) return true
    elseif opt == 'v' then print('lar version 1') return true
    elseif opt == 'x' then
      if not comp and not size then
        extr = true
      else
        printError('can not compress AND extract at the same time.')
      end
    elseif opt == 'f' then
      file = shell.resolve(arg)
    elseif opt == 'd' then
      dir = shell.resolve(arg)
    elseif opt == 'c' then
      if not extr and not size then
        comp = true
      else
        printError('can not compress AND extract at the same time.')
      end
    elseif opt == 's' then
      if not comp and not extr then
        size = true
      end
    end
  end

  if comp and dir and file then
    local ret = {}
    for k, v in pairs(listAll(dir)) do
      if not fs.isDir(v) then
        local fh = fs.open(v, 'r')
        local data = fh.readAll()
        fh.close()
        print(v)
        table.insert(ret, {
          ['data'] = data,
          ['meta'] = {
            ['size'] = #data,
            ['path'] = v,
          }
        })
      end
    end
    (run.require 'lar').write(file, ret)
    return true
  elseif extr and file then
    local dir = dir or shell.dir();
    (run.require 'lar').unlar(dir, file)
    return true
  elseif size and file then
    local tabl = (run.require 'lar').read(file)
    local size = 0

    for i = 1, #tabl do
      size = size + tabl[i].meta.size
    end

    (run.require 'info').print({
      { text = 'Total size of archive '},
      { txtCol = colors.orange, text = file},
      { txtCol = colors.red, text = '\n\tfiles: ' .. size / 1000 .. 'KB' .. '\n\tarchive file: ' .. fs.getSize(file) / 1000 .. 'KB'},
      { txtCol = colors.red, text = '\n\tpadding: ' .. fs.getSize(file) / 1000 - size / 1000 .. 'KB'}
    })

  elseif not file then
    (run.require 'info').usage('lar', 'lua archiver', '<flag> <dir>', {
      h = 'print help',
      v = 'print version',
      c = 'compress',
      v = 'toggle verbosity',
      f = 'target/input file',
      x = 'eXtract.'
    })
    return false
  end
end
