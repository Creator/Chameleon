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


function main()
  local info = run.require('libinfo')
  if info and info.printInColor then
    do
      if fs.exists('/usr/etc/motd') then
        local file = fs.open('/usr/etc/motd', 'r')
        print(file.readAll())
        file.close()
        local x, y = term.getSize()
        info.printInColor(colors.black, colors.red, string.rep('-', x))
      elseif fs.exists('/usr/etc/motd.lua') then
        local ok, err = loadfile('/usr/etc/motd.lua')
        if not ok then
          printError('error in motd: ' .. err)
        else
          ok()
        end
        local x, y = term.getSize()
        info.printInColor(
        colors.black,
        colors.red,
        string.rep('-', x))
      end

      if fs.exists('/usr/etc/release') then
        local file = fs.open('/usr/etc/release', 'r')
        info.writeInColor(colors.black, colors.white, 'initd is starting up ')
        info.printInColor(colors.black, colors.cyan, file.readAll())
        file.close()
      else
        write('initd is starting up ')
        info.printInColor(colors.black, colors.cyan, 'your TARDIX system.\n')
      end
    end
  else
    for k, v in pairs(info) do print('info.' .. k) end
  end

  if fs.exists('/usr/etc/init.d') then
    local ls = fs.list('/usr/etc/init.d')
    table.sort(ls)
    for k, v in ipairs(ls) do
      if not fs.isDir(v) then
        info.begin('Starting ' .. v:gsub('.lua', '') .. '...')
        local ret = run.spawn(fs.combine('/usr/etc/init.d', v))
        info.stop(ret or true)
      end
    end
  end

  if fs.exists('/usr/local/etc/init.d') then
    local ls = fs.list('/usr/local/etc/init.d')
    table.sort(ls)
    for k, v in ipairs(ls) do
      if not fs.isDir(v) then
        info.begin('Starting ' .. v:gsub('.lua', '') .. '...')
        local ret = run.spawn(fs.combine('/usr/etc/init.d', v))
        info.stop(ret or true)
      end
    end
  end

  if fs.exists('/usr/etc/inittab') then
    local file = fs.open('/usr/etc/inittab', 'r')
    local data = (file and textutils.unserialize(file.readAll()) or {})
    for i = 1, #data do
      local val = data[i]
      if val.daemons then
        for j = 1, #val.daemons do
          if not fs.isDir(val.daemons[j]) then
            info.begin('Starting ' .. val.daemons[j]:gsub('.lua', '') .. '...')
            local ret = run.spawn(val.daemons[j])
            info.stop(ret or true)
          end
        end
      end
    end
  end


  if fs.exists('/usr/local/etc/inittab') then
    local file = fs.open('/usr/local/etc/inittab', 'r')
    local data = (file and textutils.unserialize(file.readAll()) or {})
    for i = 1, #data do
      local val = data[i]
      if val.daemons then
        for j = 1, #val.daemons do
          if not fs.isDir(val.daemons[j]) then
            info.begin('Starting ' .. val.daemons[j]:gsub('.lua', '') .. '...')
            local ret = run.spawn(val.daemons[j])
            info.stop(ret or true)
          end
        end
      end
    end
  end

  local envs = {}

  function getenv(var)
    return envs[var]
  end

  function setenv(n, v)
    envs[var] = n
  end
  run.spawn('/usr/bin/sh.lua')

end
