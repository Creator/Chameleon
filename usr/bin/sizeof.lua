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

local function szo(d, s)
  local size = 0
  if not fs.isDir(d) and fs.exists(d) then
    return fs.getSize(d)
  end

  if fs.isDir(d) then
    local list = fs.list(d)
    for k, v in pairs(list) do
      if fs.isDir(v) then
        szo(fs.combine(d, v), size)
      else
        size = size + fs.getSize(fs.combine(d, v))
      end
    end
  end

  return size
end

function main(arg1, ...)
  local files = {arg1, ...}
  for k, v in ipairs(files) do
    print(('%s: %dB'):format(v, szo((shell and shell.resolve(v) or v))))
  end
end
