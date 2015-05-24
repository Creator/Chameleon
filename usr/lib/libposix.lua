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

function getopt(optstring, ...)
	local opts = { }
	local args = { ... }

	for optc, optv in optstring:gmatch"(%a)(:?)" do
		opts[optc] = { hasarg = optv == ":" }
	end

	return coroutine.wrap(function()
		local yield = coroutine.yield
		local i = 1

		while i <= #args do
			local arg = args[i]

			i = i + 1

			if arg == "--" then
				break
			elseif arg:sub(1, 1) == "-" then
				for j = 2, #arg do
					local opt = arg:sub(j, j)

					if opts[opt] then
						if opts[opt].hasarg then
							if j == #arg then
								if args[i] then
									yield(opt, args[i])
									i = i + 1
								elseif optstring:sub(1, 1) == ":" then
									yield(':', opt)
								else
									yield('?', opt)
								end
							else
								yield(opt, arg:sub(j + 1))
							end

							break
						else
							yield(opt, false)
						end
					else
						yield('?', opt)
					end
				end
			else
				yield(false, arg)
			end
		end

		for i = i, #args do
			yield(false, args[i])
		end
	end)
end
