# lua-uuid

[![CI](https://github.com/luau-project/lua-uuid/actions/workflows/ci.yml/badge.svg)](./.github/workflows/ci.yml)

## Overview

**lua-uuid** is a lightweight, native library for Lua (5.1 and newer) to deal with Universally Unique Id (UUID).

* On Linux, it uses ```libuuid``` to generate UUIDs;
* On Windows, it uses the WINAPI ```rpcrt4``` library.
* *(Not implemented yet)* On MacOS / iOS, it uses the ```CoreFoundation``` library.

## Table of Contents

* [Installation](#installation)
    * [Linux](#linux)
    * [Windows](#windows)
    * [MacOS / iOS](#macos--ios)
* [Usage](#usage)
    * [Generate GUIDs / UUIDs](#generate-guids--uuids)
    * [Parse GUIDs / UUIDs from string](#parse-guids--uuids-from-string)
    * [Compare GUIDs / UUIDs](#compare-guids--uuids)
    * [Verify GUIDs / UUIDs nullity](#verify-guids--uuids-nullity)
* [Future works](#future-works)

## Installation

> [!TIP]
> 
> [LuaRocks](https://luarocks.org/) is the preferred method to install ```lua-uuid```.

### Linux

On Linux, ```lua-uuid``` depends on ```libuuid```:

* On Debian-based distributions:

    ```bash
    sudo apt install -y uuid-dev
    ```

* On RedHat-based distributions:

    ```bash
    sudo dnf install libuuid-devel
    ```

After ```libuuid``` installation, assuming that ```luarocks``` is properly installed and configured on your system, execute the following command:

```bash
luarocks install lua-uuid
```

### Windows

Assuming that ```luarocks``` is installed on your system, execute the following command:

```cmd
luarocks install lua-uuid
```

### MacOS / iOS

> [!IMPORTANT]
> 
> It is not implemented at the moment.

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

## Future works

* Add CMake as build system