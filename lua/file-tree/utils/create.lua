local function create(self, props)
  local instance = props or {}

  setmetatable(instance, self)
  self.__index = self

  return instance
end

return create
