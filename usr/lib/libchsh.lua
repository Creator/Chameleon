local chsh = {}
if not _G.env then
  _G.env = {dir = '/', path = {'/usr/bin', '/bin', '/usr/sbin', '/rom/programs'}}
  do
    if term.isColor and term.isColor() then
      table.insert(_G.env.path, '/rom/programs/advanced')
    end
    if turtle then
    	table.insert(_G.env.path, "/rom/programs/turtle")
    else
        table.insert(_G.env.path, "/rom/programs/rednet")
        table.insert(_G.env.path, "/rom/programs/fun")
        if term.isColor() then
        	table.insert(_G.env.path, "/rom/programs/fun/advanced")
        end
    end
    if pocket then
        table.insert(_G.env.path, "/rom/programs/pocket")
    end
    if commands then
        table.insert(_G.env.path, "/rom/programs/command")
    end
  end
end


function chsh.resolve(path)
  for k, v in pairs(_G.env.path) do
    if fs.exists(fs.combine(v, path)) then
      return fs.combine(v, path)
    end
  end

  return false, 'no programs found'
end

function chsh.run(path, ...)
  local ret, err = tostring(chsh.resolve(path))

  if not fs.exists(ret) then
    printError('No such program ' .. exloc)
    return
  end

  return exec(ret, ...)
end

function chsh.setDir(dir)
  _G.env.dir = dir
end

function chsh.getDir()
  return _G.env.dir
end

function chsh.changeDir(dir)
  if fs.exists(fs.combine(_G.env.dir, dir)) and fs.isDir(fs.combine(_G.env.dir, dir)) then
    _G.env.dir = fs.combine(_G.env.dir, dir)
    return true
  else
    error('Can not change directory to an unexistant directory or to a file. ', 2)
    return false
  end
end

function chsh.prompt()
  return (_G.env.dir) .. ' $ '
end

return chsh
