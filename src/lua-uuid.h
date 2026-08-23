/*=================================================================================**
** LICENSE (MIT)                                                                   **
**=================================================================================**
**                                                                                 **
** The MIT License (MIT)                                                           **
**                                                                                 **
** Copyright (c) 2024 - 2026 luau-project https://github.com/luau-project/lua-uuid **
**                                                                                 **
** Permission is hereby granted, free of charge, to any person obtaining a copy    **
** of this software and associated documentation files (the "Software"), to deal   **
** in the Software without restriction, including without limitation the rights    **
** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell       **
** copies of the Software, and to permit persons to whom the Software is           **
** furnished to do so, subject to the following conditions:                        **
**                                                                                 **
** The above copyright notice and this permission notice shall be included in all  **
** copies or substantial portions of the Software.                                 **
**                                                                                 **
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR      **
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        **
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     **
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          **
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   **
** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   **
** SOFTWARE.                                                                       **
**                                                                                 **
**=================================================================================*/

#ifndef LUA_UUID_H
#define LUA_UUID_H

#define LUA_UUID_VERSION "0.1.0"

#include <lua.h>

#ifndef LUA_UUID_EXPORT
#ifdef LUA_UUID_BUILD_STATIC
#define LUA_UUID_EXPORT
#else
#ifdef LUA_UUID_BUILD_SHARED
#if defined(_WIN32) || defined(_WIN64)
#if defined(__GNUC__) || defined(__MINGW32__)
#define LUA_UUID_EXPORT __attribute__((dllexport))
#else
#define LUA_UUID_EXPORT __declspec(dllexport)
#endif
#else
#define LUA_UUID_EXPORT __attribute__((visibility("default")))
#endif
#else
#if defined(_WIN32) || defined(_WIN64)
#if defined(__GNUC__) || defined(__MINGW32__)
#define LUA_UUID_EXPORT __attribute__((dllimport))
#else
#define LUA_UUID_EXPORT __declspec(dllimport)
#endif
#else
#define LUA_UUID_EXPORT
#endif
#endif
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

LUA_UUID_EXPORT int luaopen_uuid(lua_State *L);

#ifdef __cplusplus
}
#endif

#endif
