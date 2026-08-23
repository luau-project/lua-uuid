# lua-uuid

[![LuaRocks](https://img.shields.io/luarocks/v/luau-project/lua-uuid?label=LuaRocks&color=2c3e67)](https://luarocks.org/modules/luau-project/lua-uuid)

## Overview

**lua-uuid** is a lightweight, native library for Lua (5.1 and newer) to deal with Universally Unique Id (UUID).

* On Unix-like distributions, it uses `libuuid` to generate UUIDs;
* On Windows, it uses the WINAPI `rpcrt4` library;
* On macOS / iOS, it uses the `CoreFoundation` framework.

## Table of Contents

* [Installation](#installation)
* [Usage](#usage)
    * [Generate GUIDs / UUIDs](#generate-guids--uuids)
    * [Parse GUIDs / UUIDs from string](#parse-guids--uuids-from-string)
    * [Try to parse GUIDs / UUIDs from string](#try-to-parse-guids--uuids-from-string)
    * [Compare GUIDs / UUIDs](#compare-guids--uuids)
    * [Verify GUIDs / UUIDs nullity](#verify-guids--uuids-nullity)
    * [Print the library version](#print-the-library-version)
* [Constants](#constants)
    * [version](#version)
* [Static Methods](#static-methods)
    * [new](#new)
    * [parse](#parse)
    * [tryparse](#tryparse)
* [Instance Methods](#instance-methods)
    * [isnil](#isnil)
* [Metamethods](#metamethods)
    * [__eq](#__eq)
    * [__tostring](#__tostring)
* [Change log](#change-log)
* [Future works](#future-works)

## Installation

> [!IMPORTANT]
> 
> On Unix-like distributions, `lua-uuid` depends on `libuuid`:
> 
> * On Debian-based (e.g: Ubuntu) distributions:
> 
>     ```bash
>     sudo apt install -y uuid-dev
>     ```
> 
> * On RedHat-based (e.g: Fedora) distributions:
> 
>     ```bash
>     sudo dnf install libuuid-devel
>     ```
> 
> * On BSD-based (e.g: FreeBSD) distributions:
> 
>     ```bash
>     pkg install e2fsprogs-libuuid
>     ```

Assuming that [LuaRocks](https://luarocks.org/) is properly installed and configured on your system, execute the following command:

```bash
luarocks install lua-uuid
```

## Usage

### Generate GUIDs / UUIDs

* Generate GUIDs / UUIDs and print them

    ```lua
    -- load the library
    local uuid = require("lua-uuid")

    -- generate UUIDs
    local id1 = uuid.new()
    local id2 = uuid.new()

    -- print each UUID
    print(id1)
    print(id2)
    ```

* Generate GUIDs / UUIDs and get their string representations

    ```lua
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
    ```

### Parse GUIDs / UUIDs from string

```lua
-- load the library
local uuid = require("lua-uuid")

-- parse UUIDs from string
local id1 = uuid.parse("33e4a9f2-8141-4734-a638-f2d08ee7d070")
local id2 = uuid.parse("653096e0-b09f-4626-b65e-07d4e21c70c6")

-- print each UUID
print(id1)
print(id2)
```

### Try to parse GUIDs / UUIDs from string

```lua
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
```

### Compare GUIDs / UUIDs

```lua
-- load the library
local uuid = require("lua-uuid")

-- generate UUIDs
local id1 = uuid.new()
local id2 = uuid.new()

-- print each UUID
print(id1)
print(id2)

-- prints false
print(id1 == id2)

-- prints true
print(id1 == id1)

-- prints true
print(id2 == id2)
```

### Verify GUIDs / UUIDs nullity

```lua
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
```

### Print the library version

```lua
-- load the library
local uuid = require("lua-uuid")

-- print the library version
print("lua-uuid is version " .. uuid.version)
```

## Constants

* *Description*: The library version
* *Signature*: ```version```
* *Return*: ```(string)```
* *Usage*: See [here](#print-the-library-version)

## Static Methods

### new

* *Description*: Generates a new GUID / UUID
* *Signature*: ```new()```
* *Return*: ```(userdata)```
* *Usage*: See [here](#generate-guids--uuids)

### parse

* *Description*: Parses a GUID / UUID from a string value
* *Signature*: ```parse(value)```
    * *value* (string): the string to be parsed
* *Return*: ```(userdata)```
* *Usage*: See [here](#parse-guids--uuids-from-string)

### tryparse

* *Description*: Tries to parse a GUID / UUID from a string value
* *Signature*: ```tryparse(value)```
    * *value* (string): the string to be parsed
* *Return*:
        * *obj*: an ```userdata``` representing the GUID / UUID on success or `nil` on failure;
        * *err*: `nil` on success or ```string``` containing a description of the error.
* *Usage*: See [here](#try-to-parse-guids--uuids-from-string)

## Instance Methods

### isnil

* *Description*: Verifies whether the GUID / UUID is considered null or not.

> [!NOTE]
> 
> a GUID / UUID is considered null when its string representation is equal to ```00000000-0000-0000-0000-000000000000```.

* *Signature*: ```instance:isnil()```
    * *instance* (userdata): the GUID / UUID instance to check for nullity
* *Return*: ```(boolean)```
* *Usage*: See [here](#verify-guids--uuids-nullity)

## Metamethods

### __eq

* *Description*: Compares two GUIDs / UUIDs for equality
* *Signature*: ```left == right```
    * *left* (any): the left-side element
    * *right* (any): the right-side element
* *Return*: ```(boolean)```
* *Usage*: See [here](#compare-guids--uuids)

### __tostring

* *Description*: Converts the GUID / UUID to string
* *Signature*: ```tostring(value)```
    * *value* (userdata): the GUID / UUID to perform the conversion
* *Return*: ```(string)```
* *Usage*: See [here](#generate-guids--uuids)

## History

Browse the [changelog](./CHANGELOG.md)

## Future works

* Add CMake as build system