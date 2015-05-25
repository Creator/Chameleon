function colored(n) term.setTextColor(n[2]) term.setBackgroundColor(n[1]) end function line() return { ['continue'] = function(data, other) io.write(tostring(other)) return data end, ['cont'] = function(data, other) print(other) return data end, ['brk'] = function(d) print() return d end, ['colored'] = function(d, n) term.setTextColor(n[2]) term.setBackgroundColor(n[1]) return function(data) io.write(data) term.setTextColor(colors.white) term.setBackgroundColor(colors.black) return d end end, ['colors'] = function(_, n) return function(o) term.setTextColor(colors[o]) term.setBackgroundColor(colors[n]) return _ end end, ['stop'] = function() print() end, ['center'] = function(self, sText) local w, h = term.getSize() local x, y = term.getCursorPos() x = math.max(math.floor((w / 2) - (#sText / 2)), 0) term.setCursorPos(x, y) print(sText) return self end, ['colorcenter'] = function(d, n) term.setTextColor(n[2]) term.setBackgroundColor(n[1]) return function(data) local w, h = term.getSize() local x, y = term.getCursorPos() x = math.max(math.floor((w / 2) - (#data / 2)), 0) term.setCursorPos(x, y) print(data) return d end end, ['slow'] = function(j, ...) textutils.slowPrint(...) return j end, ['slowcenter'] = function(j, data) local w, h = term.getSize() local x, y = term.getCursorPos() x = math.max(math.floor((w / 2) - (#data / 2)), 0) term.setCursorPos(x, y) textutils.slowPrint(data) return j end, ['print'] = function(j, ...) print(...) end, } end function clear() term.clear() term.setCursorPos(1,1)local _G = {} function colored(n) term.setTextColor(n[2]) term.setBackgroundColor(n[1]) end function line() return { ['continue'] = function(data, other) io.write(tostring(other)) return data end, ['cont'] = function(data, other) print(other) return data end, ['brk'] = function(d) print() return d end, ['colored'] = function(d, n) term.setTextColor(n[2]) term.setBackgroundColor(n[1]) return function(data) io.write(data) term.setTextColor(colors.white) term.setBackgroundColor(colors.black) return d end end, ['colors'] = function(_, n) return function(o) term.setTextColor(colors[o]) term.setBackgroundColor(colors[n]) return _ end end, ['stop'] = function() print() end, ['center'] = function(self, sText) local w, h = term.getSize() local x, y = term.getCursorPos() x = math.max(math.floor((w / 2) - (#sText / 2)), 0) term.setCursorPos(x, y) print(sText) return self end, ['colorcenter'] = function(d, n) term.setTextColor(n[2]) term.setBackgroundColor(n[1]) return function(data) local w, h = term.getSize() local x, y = term.getCursorPos() x = math.max(math.floor((w / 2) - (#data / 2)), 0) term.setCursorPos(x, y) print(data) return d end end, ['slow'] = function(j, ...) textutils.slowPrint(...) return j end, ['slowcenter'] = function(j, data) local w, h = term.getSize() local x, y = term.getCursorPos() x = math.max(math.floor((w / 2) - (#data / 2)), 0) term.setCursorPos(x, y) textutils.slowPrint(data) return j end, ['print'] = function(j, ...) print(...) return j end, ['write'] = function(j, ...) io.write(...) return j end, } end function clear() term.clear() term.setCursorPos(1,1) end function slow(data) textutils.slowPrint(data) end function center(sText) local w, h = term.getSize() local x, y = term.getCursorPos() x = math.max(math.floor((w / 2) - (#sText / 2)), 0) term.setCursorPos(x, y) print(sText) end function colorcenter(n) term.setTextColor(n[2]) term.setBackgroundColor(n[1]) return function(data) local w, h = term.getSize() local x, y = term.getCursorPos() x = math.max(math.floor((w / 2) - (#data / 2)), 0) term.setCursorPos(x, y) print(data) end end function wait() term.setTextColor(colors.orange) local w, h = term.getSize() local x, y = term.getCursorPos() x = math.max(math.floor((w / 2) - (#('Press any key to continue.') / 2)), 0) term.setCursorPos(x, h-1) print('Press any key to continue.') coroutine.yield('key') end function clear() term.setCursorPos(1,1) term.clear() end function exit() term.setCursorPos(1,1) term.clear() printError('End of TS document.') end end function slow(data) textutils.slowPrint(data) end function center(sText) local w, h = term.getSize() local x, y = term.getCursorPos() x = math.max(math.floor((w / 2) - (#sText / 2)), 0) term.setCursorPos(x, y) print(sText) end function colorcenter(n) term.setTextColor(n[2]) term.setBackgroundColor(n[1]) return function(data) local w, h = term.getSize() local x, y = term.getCursorPos() x = math.max(math.floor((w / 2) - (#data / 2)), 0) term.setCursorPos(x, y) print(data) end end function wait() term.setTextColor(colors.orange) local w, h = term.getSize() local x, y = term.getCursorPos() x = math.max(math.floor((w / 2) - (#('Press any key to continue.') / 2)), 0) term.setCursorPos(x, h-1) print('Press any key to continue.') coroutine.yield('key') end function clear() term.setCursorPos(1,1) term.clear() end function exit() term.setCursorPos(1,1) term.clear() printError('End of TS document.') end for k, v in pairs(colors) do _G[k] = v end for k, v in pairs(colours) do _G[k] = v end function loadpack(pack) if fs.exists('/usr/lib/ts/'..pack..'-ts.lua') then _G[pack] = {} for k, v in pairs(run.dailin.link('/usr/lib/ts/'..pack..'-ts.lua')) do _G[pack][k] = v end elseif fs.exists('/usr/local/lib/ts/'..pack..'-ts.lua') then _G[pack] = {} for k, v in pairs(run.dailin.link('/usr/local/lib/ts/'..pack..'-ts.lua')) do _G[pack][k] = v end else printError('unknown pack ' .. pack) end end

function main(...)
colored {black, lightBlue}
clear()

colorcenter {black, orange} '-- TYPE SETTER --'

line()
  :slowcenter 'Hello, world!'

colored {black, white}

line()
  : center '^ That text was written using slow.' : stop()
line()
  : center 'This is a demo of '
line()
  : colorcenter {black, red} 'Chameleon\'s '
  : colorcenter {black, blue} 'typesetter '
  : colorcenter {black, orange} 'program.'
  : brk()

  : colorcenter {black, red} 'As you can see, it is very powerful.'
  : stop()

wait()

clear()

line()
  :slowcenter '-- TypeSetter Guide --'

line()
  : colored {black, orange} 'The chameleon typesetter is a piece of software designed to make documentation writers (such as me) happy.\n'
  : print 'It is very simple to use, consisting of a lua environment override only\n'
  : print 'TypeSetter can be used as a command line utility, as a library, or to generate stand-alone programs usable anywhere.\n'
  : print 'Seeing as it is only text, it does not require an advanced computer.\n'

wait()
clear()

line()
  :slowcenter '-- Line Function --'

line()
  : colored {black, red} ':: '
  : print 'The Line function\n'

line()
  : colored {black, orange} 'The line function is used to start a new paragraph.'
  : write 'It can be used to insert line breaks, generate colored text, and manipulate text in a wide range of ways.\n'
  : colorcenter {black, orange} 'Simply put, it'
  : colorcenter {black, orange} 'is the most powerful function.\n'

line()
  : colorcenter {black, orange} 'Follows an example'
  : colorcenter {black, orange} 'of the Line function: \n'
  : colored {black, blue} [[
line()
  : colorcenter {black, orange} 'Hello, world!'
  ]]
wait()
exit()
end
if not run  then main(...) end
