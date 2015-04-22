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

TODO:
* Finalize the other OSI layers
* Error checking
*

Author: Jared Allard <rainbowdashdc@pony.so>
]]

-- needed for the network to function properally
local libNd = require('libdev')
local libNp = require('libprog')
local bit = require('libbit')
local fcs16 = require('libfcs16') -- for error-checking


-- setup object
local net = {}
logn = {}
logn.msg = {}

-- DEPRECATED
net.ip = nil

-- New system
net.inf = {}

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
function net.registerInterface(this, side)
  if type(this) ~= "table" then
    error("not called correctly, use :")
    return false
  end

  local modem = {}

  if side == nil then
    modem = libNd.get("modem")
  else
    -- TODO: check if modem exists.
    modem.name = side
  end

  -- something happened, or some interface wasn't setup correctly
  if modem == false then
    return false
  end

  -- interface table
  -- use null to make sure the entry exists, and is a string
  this.inf[modem.name] = {}
  this.inf[modem.name].ip = "null"
  this.inf[modem.name].gateway = "null"
  this.inf[modem.name].netmask = "null"

  modem.obj = peripheral.wrap(modem.name)
  modem.obj.open(65535)

  logn.write(modem.name .. " state changed to UP")
end

-- drop IPs associated with the interface
function net.deregisterInterface(side, detached)
  local modem = {}

  if side == nil then
    modem = libNd.get("modem")
  else
    -- TODO: check if modem exists.
    modem.name = side
  end

  logn.write(modem.name .. " state changed to DOWN")

  if detached ~= false then
    rednet.close(modem.name)
  end
end

--[[
    Create a packet and broadcast it onto the network

    @param {string} ip - IP to send to
    @param {string} side - modem location to broadcast over
    @param {string} msg - string to send

    @return {boolean} success or failure
]]
function net.send(this, ip, side, msg, channel)
  if type(this) ~= "table" then
    error("not called correctly, use :")
    return false
  end

  if channel == nil then
    -- default "port"
    channel = 65535
  end

  -- failsafe checks
  if tostring(this.inf[side]) == nil then
    error("interface isn't registered")
    return false
  elseif this.inf[side].ip == "null" then
    error("no ip assigned")
    return false
  end

  -- header and body
  -- body before header, must have correct checksum
  local body = base64.encode(tostring(msg))

  -- TCP header
  local header = "#" ..
    "to:".. tostring(ip) ..
    ",from:" .. tostring(this.inf[side].ip) ..
    ",destport:" .. tostring(channel) ..
    ",sourceport:" .. tostring(channel) ..
    ",seg:0" ..
    ",checksum:" .. fcs16.hash(body) ..
    ",#"

  -- form the packet
  local packet = header..body

  -- write the newly created packet to stdout
  logn.write(packet)

  -- broadcast the data to every machine on the network.
  local mod = peripheral.wrap(side)

  -- broadcast on the rednet channel
  logn.write("packet sent over mod.transmit")
  mod.transmit(65535, 65535, packet)

  return true
end

--[[
  Packet reciever, loops over net.receive()

  @return false on failure
]]
function net.d(this)
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


--[[
  Attempt to receive data back.

  @return data
]]
function net.receive(this, sid, message)
  -- TODO: Parse *only* within the first #<data>#
  -- manipulation
  local frm = tostring(string.match(message, "from:([0-9.]+),"))
  local to  = tostring(string.match(message, "to:([0-9.]+),"))
  local seg = tostring(string.match(message, "seg:([0-9]+),"))
  local destP = tostring(string.match(message, "destport:([0-9]+),"))
  local srcP = tostring(string.match(message, "sourceport:([0-9]+),"))
  local checksum = tostring(string.match(message, "checksum:([0-9]+),"))

  -- define scope
  local pdata = nil

  if tostring(this.inf[sid]) == nil then
    logv.write("CRIT: got packet, but interface ! exist")
  elseif to ~= tostring(this.inf[sid].ip) then
    logn.write("dropping packet from " .. frm .. ": ERRNOTOURS ")
  else
    -- get the data by removing the header
    pdata = tostring(string.gsub(message, "#.+#", ""))

    -- error checking
    local h = tostring(fcs16.hash(pdata))

    if h ~= checksum then
      logn.write("packet invalid [INVALIDCHECKSUM]")
    else
      logn.write("recieved: ".. pdata .. " from " .. frm)
    end
  end

  return pdata;
end

--[[
  Get all interfaces currently registered

  @return {object} o - table of interface objects
]]
function net.getInterfaces(this)
  if type(this) ~= "table" then
    error("not called correctly, use :")
    return false
  end

  local o = {}

  -- get all registered interfaces
  for i,v in pairs(this.inf) do
    table.insert(o, v)
  end

  -- return the object
  return o
end

function net.handoff(this, sid, message)
  -- TODO: Parse *only* within the first #<data>#
  -- manipulation
  local frm = tostring(string.match(message, "from:([0-9.]+),"))
  local to  = tostring(string.match(message, "to:([0-9.]+),"))
  local seg = tostring(string.match(message, "seg:([0-9]+),"))

  -- define scope
  local pdata = nil

  -- safe gaurd
  if tostring(this.inf[sid]) == nil then
    logv.write("CRIT: got packet, but interface ! exist")
  elseif to ~= tostring(this.inf[sid].ip) then
    logn.write("dropping packet from " .. frm .. ": ERRNOTOURS ")
  else
    -- get the data by removing the header
    pdata = tostring(string.gsub(message, "#.+#", ""))

    logn.write("recieved: ".. pdata .. " from " .. frm)
  end

  return pdata;
end

return net
