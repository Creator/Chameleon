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
local ProcfsObject = class(function(self, data)
  self.starttime = os.clock()
  self.proc      = (data[4] and data[4] or (getfenv(2).process.this or {}))
  self.name      = self.proc.name or ''
  self.tid       = self.proc.tid
  self.children  = self.proc.children or {}

  self.cmdline   = data[3] or ''
  self.file      = data[2] or ''
  self.where     = ('/usr/proc/%s/'):format(self.tid:sub(-4))
end)

function ProcfsObject:writeProperty(file, prop)
  if fs.exists(fs.combine(self.where, file)) then fs.delete(fs.combine(self.where, file)) end
  local x = fs.open(fs.combine(self.where, file), 'w')
  x.writeLine(prop)
  x.close()
  local e = fs.open(fs.combine(self.where, 'process_plist'), (fs.exists(fs.combine(self.where, 'process_plist')) and 'a' or 'w'))
  e.writeLine('{'..file..':'..prop..'}')
  e.close()
end

function ProcfsObject:writePropertyList(dir, propl)
  for k, v in pairs(propl) do
    local pobj = ProcfsObject:new(v)
    pobj:writeAll(dir)
  end
end

function ProcfsObject:writeAll(dir)
  self:writeProperty(fs.combine(dir or '', 'process_tid'),          self.tid      )
  self:writeProperty(fs.combine(dir or '', 'process_cmdline'),      self.cmdline  )
  self:writeProperty(fs.combine(dir or '', 'process_source'),       self.file     )
  self:writeProperty(fs.combine(dir or '', 'process_timest'),       self.starttime)
  for k, v in pairs(self.children) do
    if v.type and v:type() == 'process' then
      ProcfsObject(v):writeAll(v.tid)
    end
  end
end


return ProcfsObject