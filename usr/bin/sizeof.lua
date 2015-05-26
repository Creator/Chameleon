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

local function szo(d, s)
  local size = 512
  if not fs.isDir(d) and fs.exists(d) then
    return fs.getSize(d)
  end
  if fs.isDir(d) then
    local list = listAll(d)

    for i = 1, #list do
      if not fs.isDir(list[i]) then
        size = size + fs.getSize(list[i])
      end
    end
  end

  return size
end

local function usag()
  (run.require 'info').print({
    { txtCol = colors.red, text = 'sizeof '},
    { text = '- calculate size of a file or folder\n'},
    { text = '\tusage:\n'},
    { txtCol = colors.red, text = '\tsizeof '},
    { text = '[-h|-v] <file1[file2...]>\n'},
    { txtCol = colors.orange, text = '\t\t-h: '},
    { text = 'get this help information\n'},
    { txtCol = colors.orange, text = '\t\t-v: '},
    { text = 'get version information.'}
  })
end

local function vers()
  print('sizeof version 1')
end

function main(...)
  local files = {}

  for opt, arg in (run.require 'posix').getopt('hv', ...) do
    if opt == false then
      if fs.exists(shell.resolve(arg)) and #arg ~= 0 then
        table.insert(files, shell.resolve(arg))
      end
    elseif opt == 'h' then usag() return
    elseif opt == 'v' then vers() return end
  end

  for k, v in ipairs(files) do
    if fs.exists(v) then
      (run.require 'info').print({
        { txtCol = colors.green, text = string.format('%s: %s', fs.isDir(v) and 'd' or 'f', v)},
        { text = ' - ' .. tostring(math.floor(szo(v) / 1024)) .. 'KB (1024B)'},
      })
    end
  end
  return true

end
