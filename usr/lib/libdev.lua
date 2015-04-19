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

function dev.register(type, name)
  local obj = dev.device(type, name)
  local x = fs.open(fs.combine('/usr/dev', dev.name(type, name)), 'w')
  x.close()
  devices[dev.name(type, name)] = obj

  return obj
end

function dev.unregister(type, name)
  for k, v in pairs(devices) do
    if v.type == type and v.name == name then
      fs.delete(fs.combine('/usr/dev', dev.name(type, name)))
      print(fs.exists(fs.combine('/usr/dev', dev.name(type, name))))
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
  for k, v in pairs(peripheral.getNames()) do
    local ret = dev.register(peripheral.getType(v), v)
    table.insert(devices, ret)
  end
end

function dev.get(type, name)
  return false, 'no matching devices'
end
dev.list = devices

return dev
