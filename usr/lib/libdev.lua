local dev = {}
local dev_mt = {}
devices = {}

setmetatable(devices, {
  ["__index"] = function(t,k)
    dev.populate()
    return rawget(t,k)
  end
})

function dev.device(type, name)
  local dev = {
    ["type"] = type,
    ["name"] = name,
    ["pren"] = dev.name(type, name)
  }

  setmetatable(dev, {__index = dev_mt})
  return dev
end

function dev.short(type)
  return type:sub(1,3):lower()
end

function dev.name(type, name)
  return ("%s-%s"):format(dev.short(type), name)
end

function dev_mt.wrap()
  if self.type == 'modem' and not rednet.isOpen() then
    rednet.open(self.name)
  else
    return peripheral.wrap(self.name)
  end
end

--[[
  Register a device
]]
function dev.register(type, name)
  local obj = dev.device(type, name)
  local y = dev.name(type, name)

  -- write the block device
  local devHandle = fs.open('/usr/dev/' .. y, 'w')
  devHandle.write(type .. "," .. name)
  devHandle.close()

  -- write the object
  devices[y] = obj

  return obj
end

function dev.unregister(type, name)
  for k, v in pairs(devices) do
    if v.type == type and v.name == name then
      local y = dev.name(type, name)

      fs.delete('/usr/dev/' .. y)
      print(fs.exists('/usr/dev/' .. y))

      -- remove the obejct
      table.remove(k)
      break
    end
  end
end

function dev.unreg(pren)
  for k, v in pairs(devices) do
    if v.pren == pren then
      fs.delete(fs.combine('/usr/dev', pren))
      table.remove(k)
      break
    end
  end
end

function dev.populate()
  devices = {} -- clear on populate, should reset.
  
  for k, v in pairs(peripheral.getNames()) do
    local ret = dev.register(peripheral.getType(v), v)
    table.insert(devices, ret)
  end
end

--[[
  Get a device based on it's side, will return the first device,

  @return {boolean} success, {string} device side
]]
function dev.get(type)
  for k, v in pairs(devices) do
    if v.type == type then
      return true, v.name -- name = side
    end
  end

  -- we must've gotten nothing, so return nothing
  return false, 'no matching devices, did you populate the array?'
end

--[[
  Get a device based on it's side, will return the first device,

  @return {boolean} success, {string} device side
]]
function dev.getAll(type)
  local o = {}
  for k, v in pairs(devices) do
    if v.type == type then
      table.insert(o, devices[k])
    end
  end

  -- we must've gotten nothing, so return nothing
  return o
end

dev.list = devices

-- failsafe, populate on loadfile()
dev.populate()

return dev
