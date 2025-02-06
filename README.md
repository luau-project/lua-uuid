# lua-uuid

[![CI](https://github.com/luau-project/lua-uuid/actions/workflows/ci.yml/badge.svg)](./.github/workflows/ci.yml) [![LuaRocks](https://img.shields.io/luarocks/v/luau-project/lua-uuid?label=LuaRocks&color=2c3e67)](https://luarocks.org/modules/luau-project/lua-uuid)

## Overview

**lua-uuid** is a lightweight, native library for Lua (5.1 and newer) to deal with Universally Unique Id (UUID).

* On Unix-like distributions, it uses ```libuuid``` to generate UUIDs;
* On Windows, it uses the WINAPI ```rpcrt4``` library;
* On macOS / iOS, it uses the ```CoreFoundation``` framework.

> [!NOTE]
> 
> ```lua-uuid``` is implemented in pure ANSI C, and also compiles as C++.

## Table of Contents

* [Installation](#installation)
* [Usage](#usage)
    * [Generate GUIDs / UUIDs](#generate-guids--uuids)
    * [Parse GUIDs / UUIDs from string](#parse-guids--uuids-from-string)
    * [Compare GUIDs / UUIDs](#compare-guids--uuids)
    * [Verify GUIDs / UUIDs nullity](#verify-guids--uuids-nullity)
* [Static Methods](#static-methods)
    * [new](#new)
    * [parse](#parse)
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
> On Unix-like distributions, ```lua-uuid``` depends on ```libuuid```:
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

## Static Methods

### new

* *Description*: Generates a new GUID / UUID
* *Signature*: ```new()```
    * *return*: ```(userdata)```
* *Usage*: See [here](#generate-guids--uuids)

### parse

* *Description*: Parses a GUID / UUID from a string value
* *Signature*: ```parse(value)```
    * *value* (string): the string to be parsed
    * *return*: ```(userdata)```
* *Usage*: See [here](#parse-guids--uuids-from-string)

## Instance Methods

### isnil

* *Description*: Verifies whether the GUID / UUID is considered null or not.

> [!NOTE]
> 
> a GUID / UUID is considered null when its string representation is equal to ```00000000-0000-0000-0000-000000000000```.

* *Signature*: ```instance:isnil()```
    * *instance* (userdata): the GUID / UUID instance to check for nullity
    * *return*: ```(boolean)```
* *Usage*: See [here](#verify-guids--uuids-nullity)

## Metamethods

### __eq

* *Description*: Compares two GUIDs / UUIDs for equality
* *Signature*: ```left == right```
    * *left* (any): the left-side element
    * *right* (any): the right-side element
    * *return*: ```(boolean)```
* *Usage*: See [here](#compare-guids--uuids)

### __tostring

* *Description*: Converts the GUID / UUID to string
* *Signature*: ```tostring(value)```
    * *value* (userdata): the GUID / UUID to perform the conversion
    * *return*: ```(string)```
* *Usage*: See [here](#generate-guids--uuids)

## Change log
* v0.0.7:
    * Allowed any Unix-like distribution to build and install ```lua-uuid```, depending on the system-provided development package for ```libuuid```;
    * Added a CI job to build and test on Cygwin;
    * Now, as a Unix-like distribution, Cygwin depends on the package ```libuuid-devel```.
* v0.0.6:
> [!IMPORTANT]
> 
> This is a bug-fix release that fixed a buffer overflow in the binding of ```libuuid```. Users running older versions must upgrade as soon as possible to avoid potential exploits.
* v0.0.5:
    * Adhering to C89;
    * Added CI job to make sure that this library conforms to C89;
    * Added another CI job to assert that this library builds fine as C++ code;
    * Linting rockspecs on CI;
    * Minor changes on the makefile for macOS / iOS;
    * The naming format for the published rockspecs changed from ```vX.Y.Z-0``` to ```vX.Y.Z-1```.
* v0.0.4:
    * Added support for BSD (e.g: FreeBSD, NetBSD, OpenBSD and DragonFly);
    * Moved ```#include <lua.h>``` and ```LUA_UUID_EXPORT``` macro definition to outside of ```__cplusplus``` declarations on ```lua-uuid.h```.
* v0.0.3:
    * Changed to throw error when ```lua_newuserdata``` returns ```NULL```;
    * Added macro ```LUA_UUID_BUILD_SHARED``` to ```CFLAGS_EXTRA``` on macos;
    * Changed ```luajit-master``` to ```luajit``` on CI when testing for ```LuaJIT```;
    * Added print statements on [tostring.lua](./samples/tostring.lua) sample;
    * Removed build / testing from CI for x86 packages on MSYS2;
    * Added documentation for static, instance and metamethods to the README.
* v0.0.2:
    * Fixed syntax issue in the rockspec lua-uuid-0.0.1-0.rockspec

## Future works

* Add CMake as build system