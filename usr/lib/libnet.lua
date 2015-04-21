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

Implementation of the RFC793 standards in Lua made for the TARDIX Team.

Author: Jared Allard <rainbowdashdc@pony.so>
]]

-- needed for the network to function properally
local libNd = loadfile('/usr/lib/libdev.lua')()
local libNp = loadfile('/usr/lib/libprog.lua')()

-- setup object
local net = {}

-- use the dev API to get all available modems, then we attempt to register an IP.
-- inorder to do so, we will need a DHCP server to tell us the available APIs.
-- however, you can also set a static IP in which the machine will not need
-- a DHCP server but you will need a subnet connected by a switch.
function net:registerInterfaces()
  local modems = libNd.getAll("modem")

  for i, v in pairs(modems) do
    print(v)
  end
end

-- drop app IPs associated with the interface
function net:deregisterInterfaces()

end

-- attempt to get an IP from a DHCP server.
function net:dhcpAssoc()

end

-- attempt to unassociate from an IP from a DHCP server
function net:dhcpUnAssoc()

end

return net
