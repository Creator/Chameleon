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
  local man_path = string.split('usr/share/man:usr/local/share/man:/usr/etc/man.d:' .. (env and env.MAN_PATH or '/:'), ':')
  local section, name;
  local ts, libts = false, (run.require 'libts')

  for opt, arg in (run.require 'posix').getopt('hvT', ...) do
    if opt == false then name = arg
    elseif opt == 'h' then
      (run.require 'info').usage('man', 'read manual pages', '[section] <name>', {
        h = 'print this help information',
        v = 'print version information',
        T = 'try to render with TS.'
      }) return true
    elseif opt == 'v' then print('manual version 1') return true
    elseif opt == 'T' then ts = true end
  end
  if not name then
    (run.require 'info').usage('man', 'read manual pages', '[section] <name>', {
      h = 'print this help information',
      v = 'print version information',
      T = 'try to render with TS.'
    }) return true
  end
  if name then
    for i = 1, #man_path do
      if fs.exists(fs.combine(man_path[i], name)) then
        if ts then
          libts.run(fs.combine(fs.combine(man_path[i], ''), name))
          return true
        end
        local data = fs.open(fs.combine(man_path[i], name), 'r')
        local tabl = data.readAll()
        data.close()

        local x, y = term.getSize()

        textutils.pagedPrint(tabl, (env and env.MAN_TABSIZE) or y)
        return true
      elseif fs.exists(fs.combine(fs.combine(man_path[i], 'programs'), name)) then
        if ts then
          libts.run(fs.combine(fs.combine(man_path[i], 'programs'), name))
          return true
        end
        local data = fs.open(fs.combine(fs.combine(man_path[i], 'programs'), name), 'r')
        local tabl = data.readAll()
        data.close()

        local x, y = term.getSize()

        textutils.pagedPrint(tabl, (env and env.MAN_TABSIZE) or y)
        return true
      elseif fs.exists(fs.combine(fs.combine(man_path[i], 'libraries'), name)) then
        if ts then
          libts.run(fs.combine(fs.combine(man_path[i], 'libraries'), name))
          return true
        end

        local data = fs.open(fs.combine(fs.combine(man_path[i], 'libraries'), name), 'r')
        local tabl = data.readAll()
        data.close()

        local x, y = term.getSize()
        textutils.pagedPrint(tabl, (env and env.MAN_TABSIZE) or y)
        return true
      elseif fs.exists(fs.combine(fs.combine(man_path[i], 'utilities'), name)) then
        if ts then
          libts.run(fs.combine(fs.combine(man_path[i], 'utilities'), name))
          return true
        end
        local data = fs.open(fs.combine(fs.combine(man_path[i], 'utilities'), name), 'r')
        local tabl = data.readAll()
        data.close()

        local x, y = term.getSize()

        textutils.pagedPrint(tabl, (env and env.MAN_TABSIZE) or y)
        return true
      elseif fs.exists(fs.combine(fs.combine(man_path[i], 'sysfns'), name)) then
        if ts then
          libts.run(fs.combine(fs.combine(man_path[i], 'sysfns'), name))
          return true
        end
        local data = fs.open(fs.combine(fs.combine(man_path[i], 'sysfns'), name), 'r')
        local tabl = data.readAll()
        data.close()

        local x, y = term.getSize()

        textutils.pagedPrint(tabl, (env and env.MAN_TABSIZE) or y)
        return true
      end
    end
  end
  return false
end
