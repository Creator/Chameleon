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


local protover = "101"

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
  print("libnet: "..msg)
  table.insert(logn.msg, msg)
end

function logn.log(msg)
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
    print("not called correctly, use :")
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
  this.inf[modem.name].side = modem.name

  modem.obj = peripheral.wrap(modem.name)
  modem.obj.open(65535)

  logn.write(modem.name .. " state changed to UP")
end

function net.registerInterfaces(this)
  if type(this) ~= "table" then
    error("not called correctly, use :")
    return false
  end

  -- detect if returned an object or not
  local f = 0

  for k, v in pairs(devices) do
    if v.type == "modem" then
      -- hotlink to the registerInterface. DRY factor.
      this:registerInterface(v.name)
      f = 1
    end
  end

  if f == 0 then
    return false
  end
end

function net.deregisterInterfaces(this)
  if type(this) ~= "table" then
    error("not called correctly, use :")
    return false
  end

  -- detect if returned an object or not
  local f = 0

  for k, v in pairs(devices) do
    if v.type == "modem" then
      -- hotlink to the registerInterface. DRY factor.
      this:deregisterInterface(v.name)
      f = 1
    end
  end

  if f == 0 then
    return false
  end
end

-- drop IPs associated with the interface
function net.deregisterInterface(this, side, detached)
  local modem = {}

  if side == nil then
    modem = libNd.get("modem")
  else
    -- TODO: check if modem exists.
    modem.name = side
  end

  -- remove the inf object
  this.inf[modem.name] = nil

  logn.write(modem.name .. " state changed to DOWN")

  if detached ~= false then
    modem.obj = peripheral.wrap(modem.name)
    modem.obj.closeAll()
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

  -- START HEADER GEN --
  local header = "#version:" .. protover ..
    ",to:" .. tostring(ip) ..
    ",from:" .. tostring(this.inf[side].ip) ..
    ",destport:" .. tostring(channel) ..
    ",sourceport:" .. tostring(channel) ..
    ",seg:0" ..
    ",checksum:" .. fcs16.hash(body) ..
    ",#"
  -- END HEADER GEN --

  -- form the packet
  local packet = header..body

  -- silently log the packet data
  logn.log(packet)

  -- broadcast the data to every machine on the network.
  local mod = peripheral.wrap(side)

  -- broadcast on the rednet channel
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

--[[
  Forward a packet across interfaces.

  @return nil
]]
function net.forward(this, msg, side)
  -- [-] TODO: Sort out interfaces and broadcast accordingly.
  -- [x] TODO: regex just the to: field instead of regen.
  -- [x] TODO: Don't rely on dest.

  local inf = this.inf

  -- sort out each registered interface.
  for k, v in pairs(inf) do
    -- TODO: Optimize this to determine if we have another subnet setup.
    if tostring(v.subnet) ~= "nil" then
      logn.write("skipping side "..v.side..", ERRHASSUB")
    else
      logn.write("forwarding packet over ".. v.side)

      logn.log(v.side..": "..msg)

      local m = peripheral.wrap(v.side)
      m.open(65535)
      m.transmit(65535, 65535, msg)

      logn.write("done")
    end
  end
end

--[[
  Parse packets and determine where they should go without causing net clutter.
]]
function net.handoff(this, sid, message)
  -- TODO: Parse *only* within the first #<data>#
  -- manipulation
  local frm = tostring(string.match(message, "from:([0-9.]+),"))
  local to  = tostring(string.match(message, "to:([0-9.]+),"))
  local seg = tostring(string.match(message, "seg:([0-9]+),"))

  -- define scope
  local pdata = nil
  local isSub = false

  -- Determine if in or out
  if tostring(this.inf[sid].subnet) == "nil" then
    logn.write("error: no subnet configured, !PACKET DROPPED!")
    return false
  else
    logn.write("inspecting packet")

    -- currently only works on xxx.xxx.xxx.<dif> subnets, no xxx.xxx.<dif>.xxx
    local major = string.match(to, "^([0-9]+.[0-9]+.[0-9]+)")

    -- local subip = string.match(to, ".([0-9]+)$")
    local submj = string.match(this.inf[sid].subnet, "^([0-9]+.[0-9]+.[0-9]+)")


    if major == submj then
      logn.write("packet is on subnet")
      isSub = true
    end
  end

  -- safe gaurd
  if tostring(this.inf[sid]) == nil then
    logv.write("CRIT: got packet, but interface ! exist")
  elseif isSub == true then
    logn.write("is on local subnet, don't forward")
  else
    logn.write("passing onto this:forward")
    this:forward(message)
  end

  return pdata;
end

return net
