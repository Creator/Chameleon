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

local dir, path, rp = '/','/:/usr/bin:/usr/sbin:/rom/programs','sh';
local env = {['DIR'] = dir}

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

env.PATH = path

local shell = { aliases = {} }

env.ALIAS = shell.aliases

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
    elseif fs.exists(fs.combine(v, file) .. '.lua') then
      return fs.combine(v, file) .. '.lua'
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
  if f and fs.exists(f) and not fs.isDir(f) then
    rp = f
    local fn = fs.getDrive(f) == 'rom' and os.run or run.exece

    fn({
      ['shell'] = shell,
      ['env'] = env
    }, f, ...)
  elseif f and fs.isDir(f) then
    print('/'.. f .. ': is a directory')
    shell.setDir(f)
  end
end

function shell.getRunningProgram()
  return rp
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

shell.setAlias("ls", "list")
shell.setAlias("cp", "copy")
shell.setAlias("mv", "move")
shell.setAlias("rm", "delete")
shell.setAlias("clr", "clear")
shell.setAlias("rs", "redstone")

local tag;

if fs.exists('/.git/modules/kernel/refs/heads/rewrite') then
  local file = fs.open('/.git/modules/kernel/refs/heads/rewrite', 'r')
  local data = file.readLine():sub(1, 7)
  file.close()
  tag = data
elseif kRoot and fs.exists(fs.combine(kRoot, '.git-tag')) then
  local file = fs.open(fs.combine(kRoot, '.git-tag'), 'r')
  local data = file.readLine():sub(1, 7)
  file.close()

  tag = data
else
  tag = 'unknown'
end

function main()
  local history = {}
  while true do
    if term.isColor and term.isColor() then
      term.setTextColor(colors.blue)
    end
    print(("{time: %s} [kernel: %s]"):format(
      textutils.formatTime(os.time(), true),
      tag
    ))

    if term.isColor and term.isColor() then
      term.setTextColor(colors.red)
    end
    write(('%s $ '):format(dir == '/' and '/' or '/' .. dir))

    if term.isColor and term.isColor() then
      term.setTextColor(colors.white)
    end


    local inp = read(nil, history)
    table.insert(history, inp )
    local f, p = shell.parse(inp)

    shell.run(f, unpack(p))
  end
end

shell.main = main
return shell
