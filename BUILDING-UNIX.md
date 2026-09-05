# Building lua-uuid

This page details different methods to build `lua-uuid` directly from the source code.

## Table of Contents

* [Prerequisites](#prerequisites)
* [Build and Install](#build-and-install)

## Prerequisites

* Lua (&gt; 5.1) or LuaJIT must be installed in the system;

* On macOS, there is no need to install any external libraries. On Linux, BSD and other Unix systems, use the package manager offered by the distribution to install the development package for `libuuid`.

* CMake

Since `v0.1.0`, it is possible to employ `cmake` to build `lua-uuid` directly from the source code, out of `LuaRocks`.

> [!NOTE]
> 
> **Install CMake**: In order to use this method, the `cmake` tool is required. On macOS, visit the website [https://cmake.org/](https://cmake.org/), download and install it. On Unix distributions, use the package manager of the system to install it.

From now on, we are going to assume that `cmake` is installed in the system.

## Build and Install

1. Download the latest source code of `lua-uuid`, extract it and open a terminal in the `lua-uuid` directory;

2. Configure `lua-uuid` for the Lua version installed:

```bash
cmake -DCMAKE_BUILD_TYPE=Release -B build
```

> [!TIP]
> 
> In case multiple Lua versions are installed in the system, use `-DLUA_VERSION=5.1`, ..., `-DLUA_VERSION=5.5` to select the appropriate version for PUC-Lua or `-DLUA_VERSION=luajit` for LuaJIT.

3. Build `lua-uuid`:

```bash
cmake --build build --config Release
```

4. Test `lua-uuid`:

```bash
ctest --test-dir build -C Release
```

5. Install `lua-uuid` (_you may need to use **sudo**_):

```bash
cmake --install build --config Release
```