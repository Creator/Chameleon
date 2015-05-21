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
  while true do
    local data = {coroutine.yield()}
    run.require('libprog').daemonize()
      :addEvent('shutdown-req', function()
        (run.require 'libinfo').writeInColor(colors.black, colors.red, 'Do you want to shutdown your computer? [y/N]:')
        local info = io.read()
        if info == 'y' then
          os.shutdown()
        else
          return
        end
      end)
      :addEvent('reboot-req', function()
        (run.require 'libinfo').writeInColor(colors.black, colors.red, 'Do you want to reboot your computer? [y/N]:')
        local info = io.read()
        if info == 'y' then
          os.reboot()
        else
          return
        end
      end)
      :addEvent('shutdown', function() os.shutdown() end)
      :addEvent('reboot', function() os.shutdown() end)
      :run(unpack(data))
  end
end
