local libsys = {}
local loadmt = {
  ["run"] = function(self, scope)
    for k, v in pairs(self) do
      if v.scope == scope then
        execl(v.run.exec)
      end
    end
  end

}
function libsys.load(cfg)
  local ret = {}

  for k, v in pairs(cfg) do
    local tab = {
      ["scope"] = v.event and v.event or 0,
      ["run"] = {
        ["exec"] = v.execf and v.execf or 0,
      }
    }
    table.insert(ret, tab)
  end
  setmetatable(ret, {__index = loadmt})
  return ret
end

return libsys
