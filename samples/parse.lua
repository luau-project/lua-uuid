-- load the library
local uuid = require("lua-uuid")

-- parse UUIDs from string
local id1 = uuid.parse("33e4a9f2-8141-4734-a638-f2d08ee7d070")
local id2 = uuid.parse("653096e0-b09f-4626-b65e-07d4e21c70c6")

-- print each UUID
print(id1)
print(id2)