-- load the library
local uuid = require("lua-uuid")

-- generate UUIDs
local id1 = uuid.new()
local id2 = uuid.new()

-- get their string representations
local s1 = tostring(id1)
local s2 = tostring(id2)

assert(type(s1) == 'string')
assert(type(s2) == 'string')

-- print each string
print(s1)
print(s2)