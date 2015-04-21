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

Based off of the RFC793 standards, made by the TARDIX Team.

Author: Jared Allard <rainbowdashdc@pony.so>
]]

-- needed for the network to function properally
local libNd = loadfile('/usr/lib/libdev.lua')()
local libNp = loadfile('/usr/lib/libprog.lua')()


-- setup object
local net = {}
logn = {}
logn.msg = {}

-- placeholder
net.ip = "192.168.1.1"
net.actinf = nil

-- network log, mostly for insight on the proto
function logn.write(msg)
  print(msg)
  table.insert(logn.msg, msg)
end

-- display log
function logn.display()
  for i,v in pairs(logn.msg) do
    print(v)
  end
end

-- use the dev API to get all available modems, then we attempt to register an IP.
-- inorder to do so, we will need a DHCP server to tell us the available APIs.
-- however, you can also set a static IP in which the machine will not need
-- a DHCP server but you will need a subnet connected by a switch.
function net.registerInterface(side)
  local modem = {}

  if side == nil then
    modem = libNd.get("modem")
  else
    -- TODO: check if modem exists.
    modem.name = side
  end

  logn.write(modem.name .. " state changed to UP")
  rednet.open(modem.name)
  net.actinf = modem.name
end

-- drop IPs associated with the interface
function net.deregisterInterface(side)
  local modem = {}

  if side == nil then
    modem = libNd.get("modem")
  else
    -- TODO: check if modem exists.
    modem.name = side
  end

  logn.write(modem.name .. " state changed to DOWN")
  rednet.close(modem.name)
end

-- attempt to get an IP from a DHCP server.
function net.dhcpAssoc()

end

--[[
    Attempt to send data over rednet to the specified IP.

    This is TCP, thus we *will* wait for a response.
]]
function net.send(this, ip, msg)
  if type(this) ~= "table" then
    error("not called correctly, use :")
    return false
  end


  local header = "#to:".. tostring(ip) ..",from:".. tostring(this.ip) ..",seg:0,#"
  local body = base64.encode(tostring(msg))

  local packet = header..body

  if net.actinf == nil then
    error("no active interface")
    return false
  end

  logn.write(packet)

  -- broadcast the data to every machine on the network.
  rednet.broadcast(packet)
end

--[[
  Wait for packets, when we receive one; attempt to parse it.

  If it's out packet, we'll then parse the data!
]]
function net.d(this)
  if net.actinf == nil then
    error("no active interface")
    return false
  end

  if type(this) ~= "table" then
    error("not called correctly, use :")
    return false
  end

  -- start the rednet reciever daemon.
  while true do
    id, data = rednet.receive()

    this:receive(id, data)
  end
end

function net.qD(this)
  if type(this) ~= "table" then
    error("not called correctly, use :")
    return false
  end

  this.registerInterface()
  this:d()
end

function net.receive(this, sid, message)
  -- TODO: Parse *only* within the first #<data>#
  -- manipulation
  local frm = tostring(string.match(message, "from:([0-9.]+),"))
  local to  = tostring(string.match(message, "to:([0-9.]+),"))
  local seg = tostring(string.match(message, "seg:([0-9]+),"))

  -- define scope
  local pdata = nil

  if to ~= this.ip then
    logn.write("dropping packet from " .. frm .. ": ERRNOTOURS ")
  else
    -- get the data by removing the header
    pdata = tostring(string.gsub(message, "#.+#", ""))

    logn.write("recieved: ".. pdata .. " from " .. frm)
  end

  return pdata;
end


-- attempt to unassociate from an IP from a DHCP server
function net.dhcpUnAssoc()

end

return net
