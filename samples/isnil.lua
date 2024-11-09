-- load the library
local uuid = require("lua-uuid")

-- generate UUIDs
local id1 = uuid.new()
local id2 = uuid.new()

-- prints false
print(id1:isnil())
print(id2:isnil())

-- parse UUID
local id3 = uuid.parse("00000000-0000-0000-0000-000000000000")

-- prints true
print(id3:isnil())