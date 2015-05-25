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

local inittab = {(function(file)
  if fs.exists(file) then
    local x = fs.open(file, 'r')
    local ret = textutils.unserialize(x and x.readAll() or '{}')
    x.close()

    return unpack(ret)
  else
    return
  end
end)('/usr/etc/inittab'), (function(file)
  if fs.exists(file) then
    local x = fs.open(file, 'r')
    local ret = textutils.unserialize(x and x.readAll() or '{}')
    x.close()

    return unpack(ret)
  else
    return
  end
end)('/usr/local/etc/inittab')}

local daemons =  {};

for k, v in pairs(fs.exists('/usr/etc/init.d') and fs.list('/usr/etc/init.d') or {}) do
  daemons[#daemons + 1] = v
end

for k, v in pairs(fs.exists('/usr/local/etc/init.d') and fs.list('/usr/local/etc/init.d') or {}) do
  daemons[#daemons + 1] = v
end

local helps = {
  status = 'print status of the system.'
}

local operations = {}

function operations.status()
  local _, y = term.getSize()
  print(('-'):rep(y))
  print('Machine Status:');

  (run.require 'info').print({
    { text = 'Threads: '},
    { txtCol = colors.red, text = table.size(threading.scheduler:list(true))},
    { text = '\nDaemons: '},
    { txtCol = colors.red, text = #daemons},
    { text = '\nDaemons in inittab: '},
    { txtCol = colors.red, text = (inittab and #inittab) or 'none :('}
  })
  print(('-'):rep(y))

end

operations['sync-inittab'] = function()
  local x = fs.open('/usr/etc/inittab', 'w') do
    x.writeLine(textutils.serialize(inittab))
  x.close() end
end

operations['list-inittab'] = function()
  local _, y = term.getSize()
  print(('-'):rep(y))
  print('Inittab entries: ')

  if #inittab == 0 then
    (run.require 'libinfo').print({
      {txtCol = colors.red, text = 'No inittab entries.'}
    })
  else
    for i = 1, #inittab do
      (run.require 'libinfo').print({
        {txtCol = colors.red, text = (inittab[i])}
      })
    end
  end

  print(('-'):rep(y))
end

operations['add-inittab'] = function(arg)
  inittab[#inittab + 1] = shell.resolveP(arg)
  (run.require 'libinfo').print({
    {txtCol = colors.red, text = 'Added init table entry ' .. arg)}
  })
  local x = fs.open('/usr/etc/inittab', 'w') do
    x.writeLine(textutils.serialize(inittab))
  x.close() end
end
function main(...)
  local args, op;

  for opt, arg in (run.require 'posix').getopt('hvH:', ...) do
    if opt == false and not op then
      op = arg
    elseif opt == false and op then
      if not args then
        args = {}
      end
      table.insert(args, arg)
    elseif opt == 'h' then
      (run.require 'libinfo').usage('sysctl', 'control an initd-powered system', '<operation>', {
        h = 'print this help',
        v = 'print version information',
        H = '(uppercase) print help about a specific operation.'
      })
    elseif opt == 'H' then
      local oph = arg
      print(helps[oph])
    elseif opt == 'v' then
      print('sysctl version 1')
    end
  end
  if not op then op = 'status' end

  operations[op](args and unpack(args) or nil)
end
