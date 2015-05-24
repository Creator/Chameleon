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

function main(...)
  local repo;
  local dire;
  local branch = 'master';

  for opt, arg in getopt('hvb:s:', ...)
    if opt == false then
      if not repo and #arg ~= 0 then
        repo = arg
      elseif repo and not dire and #arg ~= 0 then
        dire = master
      end
    elseif opt == 'h' then
      (run.require 'libinfo').usage('github', 'download a repository from github', '<user/repo> <path>', {
        h = 'print this usage information',
        v = 'print version information',
        b = 'use the specified branch'
      })
      return
    elseif opt == 'v' then
      print('github downloader version 1')
      return
    elseif opt == 'b' and not branch then
      branch = arg
    elseif opt == 's' and not branch then
      branch = arg
    end
  end


  local data = (run.require 'libjson'):decode(http.format(
    textutils.urlEncode(('https://api.github.com/repos/%s/trees/%s?recursive=1'):format(repo, branch))
  ))

  if data.tree then
    for k, v in pairs(data.tree) do
      if v.type == 'blob' then
        local path = v.path
        local url = textutils.urlEncode(('https://raw.githubusercontent.com/%s/%s/%s'):format(repo, branch, path))
        local file = fs.open(fs.combine(dire, path), 'w')

        file.writeLine(http.get(url).readAll())
        file.close()
      end
    end
  end
end
