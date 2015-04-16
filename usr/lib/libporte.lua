local   libporte = {}
libporte.cache = {}
local prefix = '/'
local deps = true
function libporte.cache.parse()
  local x = fs.open('/usr/etc/laporte/cache', 'r')
  if not x then
    printError("Error trying to open cache file.")
    error()
  end
  local ret = textutils.unserialize(x.readAll())
  x.close()

  return ret
end

function libporte.cache.build()
  local data = libporte.cache.parse()
  local newData = {}
  if data and data.urls then
    newData.urls = {}
    newData.packages = {}
    for k, v in pairs(data.urls) do
      local get = http.get(v)
      local e = textutils.unserialize(get.readAll())
      newData.urls[k] = v
      if e then
        for i = 1, #e.packages do
          newData.packages[#newData.packages+1] = e.packages[i]
        end
      else
        logf('\'%s\' is not a package db.', v)
      end
    end
  else
    logf('[critical] Malformed package cache. Data %s dataurls %s')
    error()
  end
  local x = fs.open('/usr/etc/laporte/cache', 'w')
  x.writeLine(textutils.serialize(newData))
  x.close()
end

function libporte.cache.addrepo(url)
  local data = libporte.cache.parse()

  local e = textutils.unserialize(http.get(urls).readAll())
  data.urls[#data.urls+1] = e

  for i = 1, #e.packages do
    data.packages[#newData.packages+1] = e.packages[i]
  end


  local x = fs.open('/usr/etc/laporte/cache')
  x.writeLine(textutils.serialize(data)   )
  x.close()
end

function libporte.cache.query(arg)
  c = libporte.cache.parse()
  for i = 1, #c.packages do
    if c.packages[i] then
      if (c.packages[i].desc and c.packages[i].desc:find(arg))
        or (c.packages[i].name and c.packages[i].name:find(arg)) then
        print(c.packages[i].name, ": ", c.packages[i].desc)
      end
    end
  end
end


function libporte.update(arg)
  libporte.install(arg)
end

function libporte.remove(arg)
  local x = libporte.cache.parse()
  if x and x.packages then
    for i = 1, #x.packages do
      if x.packages[i].name == arg then
        for j = 1, #x.packages[i].files do
          if x.packages[i].files[j].isLar and x.packages[i].files[j].root then
            larball.deltab(fs.combine(prefix, x.packages[i].files[j].root), textutils.unserialize(dec(http.get(x.packages[i].files[j].remote).readAll())))
          else
            print('Del: ', x.packages[i].files[j].remote, '\n\tTo: ', fs.combine(prefix, x.packages[i].files[j].path))
            fs.delete(fs.combine(prefix,
              x.packages[i].files[j].path))
          end
        end
        if deps and x.packages[i].dependencies then
          for j = 1, #x.packages[i].dependencies do
            libporte.remove(x.packages[i].dependencies[j])
          end
        end
      end
    end
  else
    printError('Malformed package db.')
  end
end

function libporte.install(arg)
  local x = libporte.cache.parse()
  if x and x.packages then
    for i = 1, #x.packages do
      if x.packages[i].name == arg then
        for j = 1, #x.packages[i].files do
          local data = http.get(x.packages[i].files[j].remote)
          if not data then error("Failed: downloading file ", x.packages[i].files[j].remote) end
          if x.packages[i].files[j].isLar and x.packages[i].files[j].root then
            larball.untab(fs.combine(prefix, x.packages[i].files[j].root),
              textutils.unserialize(base64.decode(data.readAll())))
          else
            http.save(x.packages[i].files[j].remote, x.packages[i].files[j].path)
          end
        end

        if deps and x.packages[i].dependencies then
          for j = 1, #x.packages[i].dependencies do
            libporte.install(x.packages[i].dependencies[j])
          end
        end
      end
    end
  else
    printError('Malformed package db.')
  end
end

function libporte.prefix(arg)
  prefix = arg
end
function libporte.nodeps()
  deps = false
end

return libporte
