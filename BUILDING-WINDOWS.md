# Building lua-uuid

This page details different methods to build `lua-uuid` directly from the source code on Windows.

## Table of Contents

* [Prerequisites](#prerequisites)
* [Build and Install](#build-and-install)

## Prerequisites

* Lua (&gt; 5.1) or LuaJIT must be installed in the system;

* The same compiler used to build Lua or LuaJIT must be available on `PATH` environment variable.

* CMake

Since `v0.1.0`, it is possible to employ `cmake` to build `lua-uuid` directly from the source code, out of `LuaRocks`.

> [!NOTE]
> 
> **Install CMake**: In order to use this method, the `cmake` tool is required. Visit the website [https://cmake.org/](https://cmake.org/), download and install it. On Unix distributions, use the package manager of the system to install it.

From now on, we are going to assume that `cmake` is installed in the system.

## Build and Install

1. Download the latest source code of `lua-uuid`, extract it and launch the same command prompt used to build Lua;

2. Then, change directory to `lua-uuid` directory:

```batch
cd lua-uuid
```

3. Set an environment variable (`CMAKE_PREFIX_PATH`) to hold the directory of Lua (*assumed to be at `C:\Program Files\Lua`*):

```batch
set "CMAKE_PREFIX_PATH=C:\Program Files\Lua"
```

4. Configure `lua-uuid` for the Lua version installed:

    * Microsoft Visual C/C++ build tools (MSVC):

        ```batch
        cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release --install-prefix "C:\lua-uuid" -B build
        ```

    * MinGW / MinGW-w64

        ```batch
        cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release --install-prefix "C:\lua-uuid" -B build
        ```

> [!TIP]
> 
> * Change `C:\lua-uuid` below to the destination directory;
> * In case multiple Lua versions are installed in the system, use `-DLUA_VERSION=5.1`, ..., `-DLUA_VERSION=5.5` to select the appropriate version for PUC-Lua or `-DLUA_VERSION=luajit` for LuaJIT.

5. Build `lua-uuid`:

```bash
cmake --build build --config Release
```

6. Test `lua-uuid`:

```bash
ctest --test-dir build -C Release
```

7. Install `lua-uuid`:

```bash
cmake --install build --config Release
```

> [!NOTE]
> 
> Find the file `lua-uuid.dll` within `C:\lua-uuid` and copy it to any directory covered by `LUA_CPATH`.