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

local posix = (run.require 'libposix')

local function szo(d, s)
  local size = 0
  if not fs.isDir(d) and fs.exists(d) then
    return fs.getSize(d)
  end

  if fs.isDir(d) then
    local list = fs.list(d)
    for k, v in pairs(list) do
      if fs.isDir(v) then
        szo(fs.combine(d, v), size)
      else
        size = size + fs.getSize(fs.combine(d, v))
      end
    end
  end

  return size
end


local function list(dir, rec)
  if fs.isDir(dir) then
    print(('Listing directory %s'):format(dir == '/' and '/' or '/' .. dir))
    local ls = fs.list(dir)
    table.sort(ls, function(a, b)
      if fs.isReadOnly(a) and not fs.isReadOnly(b) then
        return true
      end
      if fs.isDir(a) and not fs.isDir(b) then
        return true
      end
    end)

    for k, v in pairs(ls) do
      write(('%s: '):format(fs.isDir(v) and 'd' or 'f'))
      if fs.isDir(v) and not fs.isReadOnly(v) then
        if term.isColor and term.isColor() then
          term.setTextColor(env and env.LS_COLORS and env.LS_COLORS.DIR or colors.blue)
        end
        print(v)
        if term.isColor and term.isColor() then
          term.setTextColor(colors.white)
        end
        if rec then
          dir = v
          list()
        end
      elseif fs.isReadOnly(v) then
        if term.isColor and term.isColor() then
          term.setTextColor(env and env.LS_COLORS and env.LS_COLORS.ROFILE and env.LS_COLORS.ROFILE or colors.red)
        end
        print(v)
        if term.isColor and term.isColor() then
          term.setTextColor(colors.white)
        end
      else
        if term.isColor and term.isColor() then
          term.setTextColor(env and env.LS_COLORS and env.LS_COLORS.FILE or colors.green)
        end
        print(v)
        if term.isColor and term.isColor() then
          term.setTextColor(colors.white)
        end
      end
    end
  else
    printError('something!')
  end
end

function main(arg1)
  if arg1 == '-h' then
    print(('usage:\n'..
    '\t%s [-h]\n'..
    '\t -h: display this help information and exit\n'):format(_FILE or 'lsa'))
    return
  elseif arg1 then
    list(shell.resolve(arg1), false)
  else
    list(shell.dir(), false)
  end
  return
end
