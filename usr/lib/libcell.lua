local libcell = {}

function libcell.generate(data, to)
  local tmpfiles = {}
  if not data.files
    or not data.name
    or not data.install then
      error('Invalid/corrupt data.')
  else
    printf(':: Generating cell \'%s\'.\n', data.name)
    printf('-> Compiling required files.')
    for k, v in pairs(data.files) do
      local rID = getRandomString('xxyy-xyy-xxyy')
      if not v.source and v.remote then
        v.source = ("/tmp/%s/%s"):format(data.name, rID)
        local x = http.get(v.remote)
        print(v.source)
        local h = fs.open(v.source, 'w')
        h.write(x.readAll())
        h.close()
      end
      if not fs.exists(v.source) then
        printf('-> Error: file \'%s\' (required for \'%s\') doesn\'t exist.', v.source, v.output)
        error()
      end
      printf('\t-> Compiling \'%s\'.', v.source, fs.combine('/tmp', data.name), v.output)

      ExecutableWriter()
        :addMainFunction(loadfile(v.source))
        :write(fs.combine(fs.combine('/tmp', data.name), v.output))

    end
    local tab = {}
    print('-> Generating archive.')
    for k, v in pairs(data.install) do
      printf('\t-> Archiving \'%s\'.', v.target)
      print(fs.combine(fs.combine('/tmp', data.name),v.source))
      local source = fs.open(fs.combine(fs.combine('/tmp', data.name),v.source), 'r')
      local srcdat = source.readAll()
      source.close()

      table.insert(tab, {
        ['data'] = srcdat,
        ['meta'] = {
          ['path'] = v.target,
          ['size'] = #srcdat
        }
      })
    end
    printf('-> Writing archive \'%s\'.', to)
    local count = 0
    local x = fs.open(to, 'w')
    for k, v in pairs(tt(base64.encode(textutils.serialize(tab)), 64)) do
      x.writeLine(v)
      count = count + 1
      if count == 16 then
        x.writeLine('')
        count = 0
      end
    end
    x.close()
    printf('-> Done writing archive \'%s\'.', to)
  end
  printf('-> Removing temporary files.')
  fs.delete(('/tmp/%s'):format(data.name))
  printf('-> Done removing temporary files.')
  printf('\n:: Done.')
end

function libcell.install(path)
  printf(':: Expand \'%s\'.', path)
  local data = fs.open(path, 'r')
  local tab = textutils.unserialize(base64.decode(data.readAll()))
  data.close()

  printf("\t-> Files to inflate: %d", #tab)
  for i = 1, #tab do
    printf('\t-> Inflate \'%s\'', tab[i].meta.path)
    local file = fs.open(fs.combine('/usr/local', tab[i].meta.path), 'w')
    file.writeLine(tab[i].data)
    file.close()
  end
  printf(':: Done.')
end

return libcell