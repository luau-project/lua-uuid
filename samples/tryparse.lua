-- load the library
local uuid = require("lua-uuid")

-- try to parse UUIDs from string
local id1, err1 = uuid.tryparse("some random string")
local id2, err2 = uuid.tryparse("653096e0-b09f-4626-b65e-07d4e21c70c6")

-- print each UUID
if (id1 == nil) then
    -- this branch is going
    -- to execute, because
    -- the string is not
    -- a valid GUID / UUID
    print(err1)
else
    print(id1)
end

if (id2 == nil) then
    print(err2)
else
    -- this branch is going
    -- to execute
    print(id2)
end