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
  local args = {}

  for opt, arg in (run.require 'posix').getopt('hv', ...) do
    if opt == false then
      if #arg >= 0 then
        table.insert(args, arg)
      end
    elseif opt == 'h' then
      (run.require 'info').usage('env', 'manipulate the environment', '<param1=value[param2=value...]>', {
        h = 'print this help information',
        v = 'print version information'
      }) return
    elseif opt == 'v' then print('env version 1') return end
  end

  if not (#args == 0) then
    for k, v in ipairs({...}) do
      local split = string.split(v, '=')
      env[split[1]] = split[2]
      print(v)
    end
  else
    if env then
      for k, v in pairs(env) do
        print(('%s=%s'):format(k, textutils.serialize(v)))
      end
    end
  end
  return true

end
