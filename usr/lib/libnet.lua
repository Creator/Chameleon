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
  * UDP/TCP (UDP done)

Coding Style:

  * when you are unsure of a type, always tostring it.
  * tab = 3 spaces.


Author: Jared Allard <rainbowdashdc@pony.so>
]]

-- needed for the network to function properally
local libNd = require('libdev')
local libNp = require('libprog')
local bit = require('libbit')
local fcs16 = require('libfcs16') -- for error-checking

-- versions (not in binary)
local tcpver = "101"
local ipv4ver = "100"


-- setup object
local net = {}
logn = {}
logn.msg = {}

-- interface table
net.inf = {}

-- table for types
net.layers = {}
net.layers.transport = {}
net.layers.network = {}
net.layers.data = {}

-- setup each table type
net.layers.transport["tcp"] = true
net.layers.network["ipv4"] = true
net.layers.data["data"] = true

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
  elseif ip == nil then
    error("ip param missing")
    return false
  elseif side == nil then
    error("inf side param missing")
    return false
  elseif msg == nil then
    error("msg param missing")
    return false
  end

  -- body layer is the data layer.
  local body = "layer:data" ..
    ",data:" .. base64.encode(tostring(msg))

  -- [x] TODO: seperate the TCP layer from the IPv4 layer
  -- [x] TODO: (re)implement the IPv4 layer
  -- [ ] TODO: Implement the new data layer.
  -- [ ] TODO: Implement the ICMP layer.
  -- [ ] TODO: have tcp checksum all of it's layers.
  -- [ ] TODO: create a TCP checksum for it's actual header.

  -- TCP Layer
  local tcp = "layer:tcp" ..
    ",version:" .. tcpver ..
    ",dest:" .. tostring(channel) ..
    ",source:" .. tostring(channel) ..
    ",ack:" .. tostring(0) .. -- todo
    ",fin:" .. tostring(0) .. -- todo as well
    ",seg:0" ..
    ",checksum:" .. fcs16.hash(body) ..
    ",;"

  -- IPv4 Layer
  local ipv4 = "layer:ipv4" ..
    ",version:" .. ipv4ver ..
    ",tl:10000" ..
    ",id:" .. net:genIPv4ID() ..
    ",flag:1" ..  -- don't fragment (yet)
    ",source:" .. tostring(this.inf[side].ip) ..
    ",dest:" .. tostring(ip)

  -- IPv4 checksum
  ipv4 = ipv4 ..
    ",checksum:" .. fcs16.hash(ipv4) ..
    ",;"

  local header = "#" .. tcp .. ipv4 .. "#" -- encasp it into the header field,

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

function net.genIPv4ID()
  return 000000 -- placeholder
end

--[[
  Packet reciever, loops over net.receive()

  NOTE: This blocks.

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
  -- [x] TODO: implement layer parsing, with fallsafe if corrupt
  -- [ ] TODO: (re)Implement TCP libnet specs.
  -- [ ] TODO: (re)Implement the new IPv4 specs.
  -- [ ] TODO: Implement the new ICMP specs.

  -- set up the layer tables
  icmp = {}
  tcp  = {}
  ipv4 = {}
  data = {}

  -- first we parse the transport layer.
  for i,v in pairs(string.split(message, ";")) do
    -- remove the hash(es)
    v = string.gsub(v, "#", "")
    -- log the data.
    logn.log(v)

    -- parse the layer type
    local layer = tostring(string.match(v, "layer:([a-z0-9]+),"))
    logn.log("layer [".. tostring(i) .. "] protocol is "..layer)

    -- check layer order
    if i == 1 then
      if this.layers.transport[layer] ~= true then
        logn.write("1st layer is not a transport layer?")
        return false
      end
    elseif i == 2 then
      if this.layers.network[layer] ~= true then
        logn.write("2nd layer is not a network layer?")
        return false
      end
    elseif i == 3 then
      if this.layers.data[layer] ~= true then
        logn.write("3rd layer is not a data layer?")
        return false
      end
    end

    -- check layer type
    if layer == "tcp" then
      logn.write("parsing layer tcp")

      -- parse the TCP data
      tcp.version = tostring(string.match(v, "version:([0-9]+),"))
      tcp.seg = tostring(string.match(v, "seg:([0-9]+),"))
      tcp.destP = tostring(string.match(v, "dest:([0-9]+),"))
      tcp.srcP = tostring(string.match(v, "source:([0-9]+),"))
      tcp.ack = tostring(string.match(v, "ack:([0-9]+),"))
      tcp.fin = tostring(string.match(v, "fin:([0-9]+),"))
      tcp.checksum = tostring(string.match(v, "checksum:([0-9]+),"))
    elseif layer == "ipv4" then
      logn.write("parsing layer ipv4")

      -- parse the ipv4 layer
      ipv4.version = tostring(string.match(v, "version:([0-9]+),"))
      ipv4.ttl = tostring(string.match(v, "ttl:([0-9]+),"))
      ipv4.id = tostring(string.match(v, "id:([0-9]+),"))
      ipv4.flag = tostring(string.match(v, "flag:([0-9]+),"))
      ipv4.dest = tostring(string.match(v, "dest:([0-9.]+),"))
      ipv4.source = tostring(string.match(v, "source:([0-9.]+),"))
      ipv4.protocol = tostring(string.match(v, "protocol:([0-9a-zA-Z]+),"))
      ipv4.checksum = tostring(string.match(v, "checksum:([0-9]+),"))
    elseif layer == "data" then
      logn.write("parsing layer data")

      -- parse the data layer
      data.data = tostring(string.match(v, "data:([a-zA-Z=]+)"))
      data.data = base64.decode(data.data) -- unmask the data
    else
      logn.write("unknown layer received")
    end
  end

  local fData = nil

  -- parse it!
  if tostring(this.inf[sid]) == nil then
    logn.write("CRIT: got packet, but interface ! exist")
  elseif ipv4.dest ~= tostring(this.inf[sid].ip) then
    logn.write("dropping; from " .. ipv4.source .. ": ERRNOTOURS ["..ipv4.dest.."] ")
  else
    fData = data.data
    logn.write("recieved: ".. tostring(fData) .. " from " .. ipv4.source)
  end

  return fData;
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
  explodes an IP into a table per digit.
]]
function net.ipToTable(ip)
  local tip = string.split(ip, ".")

  return tip
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

  -- failsafe
  if tostring(this.inf[sid]) == nil then
    logv.write("CRIT: got packet, but interface ! exist")

  -- if it has a subnet, don't broadcast it there.
  -- TODO: broadcast it there if it matchs that network.
  elseif isSub == true then
    logn.write("is on local subnet, don't forward")
  else
    logn.write("passing onto this:forward")
    this:forward(message)
  end

  return pdata;
end

return net
