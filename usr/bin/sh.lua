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
]]

local dir, path = '/','/:/usr/bin:/usr/sbin:/rom/programs';

if term.isColor() then
	path = path..":/rom/programs/advanced"
end

if turtle then
	path = path..":/rom/programs/turtle"
else
    path = path..":/rom/programs/rednet:/rom/programs/fun"
    if term.isColor() then
    	path = path..":/rom/programs/fun/advanced"
    end
end

if pocket then
    path = path..":/rom/programs/pocket"
end

if commands then
    path = path..":/rom/programs/command"
end

if http then
	path = path..":/rom/programs/http"
end

local shell = { aliases = {} }

function shell.isAlias(file)
  return shell.aliases[file]
end

function shell.setAlias(n, o)
  shell.aliases[n] = shell.resolveP(o)
end

function shell.getAlias(s)
  return shell.isAlias(s) and shell.aliases[s]
end

function shell.resolveP(file)
  if shell.isAlias(file) then
    return shell.getAlias(file)
  end

  if fs.exists(fs.combine(shell.dir(), file)) then
    return fs.combine(shell.dir(), file)
  end
  for k, v in pairs(string.split(path, ':')) do
    if fs.exists(fs.combine(v, file)) then
      return (fs.combine(v, file))
    end
  end

  printError('failed to find file')
end

function shell.resolve(_sPath)
	local sStartChar = string.sub(_sPath, 1, 1)
	if sStartChar == "/" or sStartChar == "\\" then
		return fs.combine("", _sPath)
	else
		return fs.combine(shell.dir(), _sPath)
	end
end

function shell.run(file, ...)
  local f = shell.resolveP(file)
  if f then
    local fn = fs.getDrive(f) == 'rom' and os.run or run.exece

    fn({
      ['shell'] = shell
    }, f, ...)
  end
end

function shell.parse(str)
  local x = string.split(str, ' ')
  local file = x[1]
  local pars = table.from(x, 2)

  return file, pars
end

function shell.setDir(nDir)
  dir = nDir
end

function shell.getDir()
  return dir
end

shell.dir = shell.getDir

function shell.setPath(nPath)
  path = nPath
end

function shell.getPath()
  return path
end

function shell.exit()
  error(2)
end


function main()
  while true do
    if term.isColor and term.isColor() then
      term.setTextColor(colors.red)
    end

    write(dir .. ' $ ')

    if term.isColor and term.isColor() then
      term.setTextColor(colors.white)
    end


    local inp = read()
    local f, p = shell.parse(inp)

    shell.run(f, unpack(p))
  end
end

shell.main = main
return shell
