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

local env = {}

function env.colored(n)
  term.setTextColor(n[2])
  term.setBackgroundColor(n[1])
end

function env.line()
  return {
    ['continue'] = function(data, other)
      io.write(tostring(other))
      return data
    end,
    ['cont'] = function(data, other)
      print(other)
      return data
    end,
    ['brk'] = function(d)
      print()
      return d
    end,
    ['colored'] = function(d, n)
      term.setTextColor(n[2])
      term.setBackgroundColor(n[1])
      return function(data)
        io.write(data)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        return d
      end
    end,
    ['colors'] = function(_, n)
      return function(o)
        term.setTextColor(colors[o])
        term.setBackgroundColor(colors[n])
        return _
      end
    end,
    ['stop'] = function()
      print()
    end,
    ['center'] = function(self, sText)
      local w, h = term.getSize()
      local x, y = term.getCursorPos()
      x = math.max(math.floor((w / 2) - (#sText / 2)), 0)
      term.setCursorPos(x, y)

      print(sText)
      return self
    end,
    ['colorcenter'] = function(d, n)
      term.setTextColor(n[2])
      term.setBackgroundColor(n[1])
      return function(data)
        local w, h = term.getSize()
        local x, y = term.getCursorPos()
        x = math.max(math.floor((w / 2) - (#data / 2)), 0)
        term.setCursorPos(x, y)

        print(data)
        return d
      end
    end,
    ['slow'] = function(j, ...)
      textutils.slowPrint(...)
      return j
    end,
    ['slowcenter'] = function(j, data)
      local w, h = term.getSize()
      local x, y = term.getCursorPos()
      x = math.max(math.floor((w / 2) - (#data / 2)), 0)
      term.setCursorPos(x, y)
      textutils.slowPrint(data)

      return j
    end,
    ['print'] = function(j, ...)
      print(...)
      return j
    end,
    ['write'] = function(j, ...)
      io.write(...)
      return j
    end,
  }
end

function env.clear()
  term.clear()
  term.setCursorPos(1,1)
end

function env.slow(data)
  textutils.slowPrint(data)
end

function env.center(sText)
  local w, h = term.getSize()
  local x, y = term.getCursorPos()
  x = math.max(math.floor((w / 2) - (#sText / 2)), 0)
  term.setCursorPos(x, y)

  print(sText)
end

function env.colorcenter(n)
  term.setTextColor(n[2])
  term.setBackgroundColor(n[1])
  return function(data)
    local w, h = term.getSize()
    local x, y = term.getCursorPos()
    x = math.max(math.floor((w / 2) - (#data / 2)), 0)
    term.setCursorPos(x, y)

    print(data)
  end
end

function env.wait()
  term.setTextColor(colors.orange)

  local w, h = term.getSize()
  local x, y = term.getCursorPos()
  x = math.max(math.floor((w / 2) - (#('Press any key to continue.') / 2)), 0)
  term.setCursorPos(x, h-1)

  print('Press any key to continue.')

  coroutine.yield('key')
end

function env.exit()
  term.setCursorPos(1,1)
  term.clear()
end


function env.loadpack(pack)
  if fs.exists('/usr/lib/ts/'..pack..'-ts.lua') then
    env[pack] = {}
    for k, v in pairs(run.dailin.link('/usr/lib/ts/'..pack..'-ts.lua')) do
      env[pack][k] = v
    end
  elseif fs.exists('/usr/local/lib/ts/'..pack..'-ts.lua') then
    env[pack] = {}
    for k, v in pairs(run.dailin.link('/usr/local/lib/ts/'..pack..'-ts.lua')) do
      env[pack][k] = v
    end
  else
    printError('unknown pack ' .. pack)
  end
end



for k, v in pairs(colors) do
  env[k] = v
end

for k, v in pairs(colours) do
  env[k] = v
end

local ret = {}

function ret.main(...)
  local name;

  for opt, arg in (run.require 'posix').getopt('hv', ...) do
    if opt == false then name = shell.resolve(arg)
    elseif opt == 'h' then
      (run.require 'info').usage('ts', 'type setter utility', '<file>', {
        h = 'print this help information',
        v = 'print version information'
      }) return
    elseif opt == 'v' then print('manual version 1') return end
  end

  if name then
    local ok, err = loadfile(name)
    if not ok then
      printError('error loading typesetter file ' .. name .. ':\n\t' .. err)
      return
    end
    setfenv(ok, env)
    ok()
  else
    (run.require 'info').usage('ts', 'type setter utility', '<file>', {
      h = 'print this help information',
      v = 'print version information'
    }) return
  end
end


function ret.run(name)
  local ok, err = loadfile(name)
  if not ok then
    printError('error loading typesetter file ' .. name .. ':\n\t' .. err)
    return
  end
  setfenv(ok, env)
  ok()
end

return ret
