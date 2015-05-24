--[[
The MIT License (MIT)

Copyright (c) 2014-2015 the TARDIX team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]

--[[
Information output library.
]]
local libinfo = {}

function libinfo.printInColor(bg, fg, str)
  if term.isColor and term.isColor() then
    term.setBackgroundColor(bg)
    term.setTextColor(fg)
  end
  print(str)
end

function libinfo.writeInColor(bg, fg, str)
  if term.isColor and term.isColor() then
    term.setBackgroundColor(bg)
    term.setTextColor(fg)
  end
  write(str)
end

function libinfo.begin(name)
  libinfo.printInColor(colors.black, colors.white, '['..os.clock()..'] ' .. name .. '')
end

function libinfo.stop(status)
  if status then
    local x, y = term.getSize()
    local cx, cy = term.getCursorPos()
    term.setCursorPos(x - #('[ OK ]'), cy - 1)

    libinfo.printInColor(colors.black, colors.green, '[ OK ]')
  else
    local x, y = term.getSize()
    local cx, cy = term.getCursorPos()
    term.setCursorPos(x - #('[ FAIL ]'), cy - 1)

    libinfo.printInColor(colors.black, colors.red, '[ FAIL ]')
  end

  if term.isColor and term.isColor() then
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
  end
end

function libinfo.ok(thing)
  libinfo.begin(thing)
  libinfo.stop(true)
end

function libinfo.fail(thing)
  libinfo.begin(thing)
  libinfo.stop(false)
end

function libinfo.print(tOfLines)
  for i = 1, #tOfLines do
    local val = tOfLines[i]
    if val.txtCol then
      if term.isColor and term.isColor() then
        term.setTextColor(val.txtCol)
      end
    else
      term.setTextColor(colors.white)
    end

    if val.bgCol then
      if term.isColor and term.isColor() then
        term.setBackgroundColor(val.bgCol)
      end
    else
      term.setBackgroundColor(colors.black)
    end

    if val.pos then
      local cx, cy = term.getSize()
      if val.pos.x and val.pos.y then
        term.setCursorPos(val.pos.y, val.pos.x)
      elseif val.pos.x then
        term.setCursorPos(cy, val.pos.x)
      elseif val.pos.y then
        term.setCursorPos(val.pos.y, cx)
      end
    end

    if val.text then
      if i == #tOfLines then
        print(val.text)
      else
        io.write(val.text)
      end
    end
  end

  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
end

function libinfo.usage(name, desc, gen, opts)
  local function keys(opts)
    local ret = {}
    for k, v in pairs(opts) do
      table.insert(ret, '-' .. k)
    end

    return ret
  end
  local toPrint = {
    { txtCol = colors.red, text = name},
    { text = ' - '.. desc .. '\n'},
    { text = '\tusage:\n'},
    { txtCol = colors.red, text =  '\t\t' .. name},
    { text = ' [' .. table.concat(keys(opts), '|') .. '] ' .. gen .. '\n'},
  }
  local i = 0

  for k, v in pairs(opts) do
    i = i + 1

    table.insert(toPrint, {
      txtCol = colors.orange, text = '\t\t-'.. k .. ': '
    })
    if i == table.size(opts) then
      table.insert(toPrint, {
        text = v
      })
    else
      table.insert(toPrint, {
        text = v .. '\n'
      })
    end
  end

  libinfo.print(toPrint)
end

return libinfo
