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
  if info then
    do
      if fs.exists('/usr/etc/motd') then
        local file = fs.open('/usr/etc/motd', 'r')
        print(file.readAll())
        file.close()
      elseif fs.exists('/usr/etc/release') then
        local file = fs.open('/usr/etc/release', 'r')
        write('initd is starting up ')
        info.printInColor(colors.black, colors.cyan, file.readAll())
        file.close()
      else
        write('initd is starting up ')
        info.printInColor(colors.black, colors.cyan, 'your TARDIX system.\n')
      end
    end
  else
    print(info)
  end

  if fs.exists('/usr/etc/init.d') then
    for k, v in pairs(fs.list('/usr/etc/init.d')) do
      info.begin('Starting ' .. v:gsub('.lua', '') .. '...')
      local ret = run.spawn(fs.combine('/usr/etc/init.d', v))
      info.stop(ret or true)
    end
  end
  local envs = {}

  function getenv(var)
    return envs[var]
  end

  function setenv(n, v)
    envs[var] = n
  end
  run.spawn('/rom/programs/lua')

end
