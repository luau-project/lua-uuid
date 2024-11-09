-- load the library
local uuid = require("lua-uuid")

-- generate UUIDs
local id1 = uuid.new()
local id2 = uuid.new()

-- print each UUID
print(id1)
print(id2)

-- compare UUIDs for equality
print(id1 == id2)
print(id1 == id1)
print(id2 == id2)