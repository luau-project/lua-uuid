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

#include "lua-uuid.h"

#if defined(LUA_UUID_USE_WIN32)
#include <rpc.h>
#elif defined(LUA_UUID_USE_LIBUUID)
#include <uuid/uuid.h>
#elif defined(LUA_UUID_USE_APPLE)
#include <CoreFoundation/CFUUID.h>
#define LUA_UUID_IS_NULL(u) (((u).byte0  == 0) && \
    ((u).byte1  == 0) && \
    ((u).byte2  == 0) && \
    ((u).byte3  == 0) && \
    ((u).byte4  == 0) && \
    ((u).byte5  == 0) && \
    ((u).byte6  == 0) && \
    ((u).byte7  == 0) && \
    ((u).byte8  == 0) && \
    ((u).byte9  == 0) && \
    ((u).byte10 == 0) && \
    ((u).byte11 == 0) && \
    ((u).byte12 == 0) && \
    ((u).byte13 == 0) && \
    ((u).byte14 == 0) && \
    ((u).byte15 == 0))
#else
#error "Unknown configuration to build lua-uuid. \
        Please, compile with `-DLUA_UUID_USE_WIN32`, \
        `-DLUA_UUID_USE_LIBUUID` or \
        `-DLUA_UUID_USE_APPLE`"
#endif

#include <string.h>
#include <luaconf.h>
#include <lauxlib.h>
#include <lualib.h>

typedef struct tagLuaUuid
{
#if defined(LUA_UUID_USE_WIN32)
    UUID data;
#elif defined(LUA_UUID_USE_LIBUUID)
    uuid_t data;
#elif defined(LUA_UUID_USE_APPLE)
    CFUUIDRef data;
#endif
} LuaUuid;

/*
** 
** String buffer capacity
** to hold a string representation
** of the GUID / UUID.
** 
** Each character (16 chars) expands
** to 2 bytes each (16 * 2)
** + 4 hyphens
** + 1 null-terminator.
** 
** As a safety measure, we double the number
** to avoid any potential overflow.
 */
#define LUA_UUID_BUFFER_LEN ((16 * 2 + 4 + 1) * 2)

/*
** 
** Metatable for GUID / UUID
** 
*/
#define LUA_UUID_METATABLE "lua-uuid-metatable"

static LuaUuid *lua_uuid_check(lua_State *L, int index)
{
    void *ud = luaL_checkudata(L, index, LUA_UUID_METATABLE);
    luaL_argcheck(L, ud != NULL, index, "LuaUuid expected");
    return (LuaUuid *)ud;
}

/*
** The following function
** was copied from Lua 5.4
** source code in order
** to provide compatibility
** to Lua 5.1 and Lua 5.2
*/
static void *lua_uuid_testudata(lua_State *L, int ud, const char *tname)
{
#if LUA_VERSION_NUM == 501 || LUA_VERSION_NUM == 502
    void *p = lua_touserdata(L, ud);
    if (p != NULL)
    {
        if (lua_getmetatable(L, ud))
        {
            luaL_getmetatable(L, tname);
            if (!lua_rawequal(L, -1, -2))
            {
                p = NULL;
            }

            lua_pop(L, 2);
            return p;
        }
    }
    return NULL;
#else
    return luaL_testudata(L, ud, tname);
#endif
}

static int lua_uuid_new(lua_State *L)
{
#if defined(LUA_UUID_USE_WIN32)
    RPC_STATUS create_status;
#elif defined(LUA_UUID_USE_LIBUUID)
    /* do nothing */
#elif defined(LUA_UUID_USE_APPLE)
    /* do nothing */
#endif

    LuaUuid *uuid = (LuaUuid *)lua_newuserdata(L, sizeof(LuaUuid));
    if (uuid == NULL)
    {
        return luaL_error(L, "Failed to create userdata");
    }

    luaL_getmetatable(L, LUA_UUID_METATABLE);
    lua_setmetatable(L, -2);

#if defined(LUA_UUID_USE_WIN32)
    create_status = UuidCreate(&(uuid->data));

    if (create_status != RPC_S_OK)
    {
        return luaL_error(L, "Failed to create UUID");
    }
#elif defined(LUA_UUID_USE_LIBUUID)
    uuid_generate(uuid->data);
#elif defined(LUA_UUID_USE_APPLE)
    uuid->data = CFUUIDCreate(NULL);

    if (uuid->data == NULL)
    {
        return luaL_error(L, "Failed to create UUID");
    }
#endif

    return 1;
}

static int lua_uuid_parse(lua_State *L)
{
    LuaUuid *uuid;
    const char *s = luaL_checkstring(L, 1);

#if defined(LUA_UUID_USE_WIN32)
    UUID data;
    RPC_STATUS parse_status = UuidFromStringA((RPC_CSTR)s, &data);

    if (parse_status != RPC_S_OK)
    {
        return luaL_error(L, "Failed to parse UUID");
    }

#elif defined(LUA_UUID_USE_LIBUUID)
    uuid_t data;
    int parse_status = uuid_parse(s, data);

    if (parse_status != 0)
    {
        return luaL_error(L, "Failed to parse UUID");
    }

#elif defined(LUA_UUID_USE_APPLE)
    CFUUIDRef data;
    CFUUIDBytes uuid_bytes;
    int is_nil_uuid_str = strcmp("00000000-0000-0000-0000-000000000000", s) == 0;
    CFStringRef strRef = CFStringCreateWithCString(NULL, s, kCFStringEncodingISOLatin1);

    if (strRef == NULL)
    {
        return luaL_error(L, "Failed to create string ref");
    }

    data = CFUUIDCreateFromString(NULL, strRef);

    CFRelease(strRef);

    if (data == NULL)
    {
        return luaL_error(L, "Failed to parse UUID");
    }

    uuid_bytes = CFUUIDGetUUIDBytes(data);
    if ((!is_nil_uuid_str) && LUA_UUID_IS_NULL(uuid_bytes)) {
        CFRelease(data);
        return luaL_error(L, "Failed to parse UUID");
    }
#endif

    uuid = (LuaUuid *)lua_newuserdata(L, sizeof(LuaUuid));
    if (uuid == NULL)
    {
#if defined(LUA_UUID_USE_WIN32)
        /* do nothing */
#elif defined(LUA_UUID_USE_LIBUUID)
        /* do nothing */
#elif defined(LUA_UUID_USE_APPLE)
        CFRelease(data);
#endif
        return luaL_error(L, "Failed to create userdata");
    }

    luaL_getmetatable(L, LUA_UUID_METATABLE);
    lua_setmetatable(L, -2);

#if defined(LUA_UUID_USE_WIN32)
    memcpy(&(uuid->data), &data, sizeof(UUID));
#elif defined(LUA_UUID_USE_LIBUUID)
    memcpy(uuid->data, data, sizeof(uuid_t));
#elif defined(LUA_UUID_USE_APPLE)
    memcpy(&(uuid->data), &data, sizeof(CFUUIDRef));
#endif

    return 1;
}

static int lua_uuid_tryparse(lua_State *L)
{
    LuaUuid *uuid;
    const char *s = luaL_checkstring(L, 1);

#if defined(LUA_UUID_USE_WIN32)
    UUID data;
    RPC_STATUS parse_status = UuidFromStringA((RPC_CSTR)s, &data);

    if (parse_status != RPC_S_OK)
    {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to parse UUID");
        return 2;
    }

#elif defined(LUA_UUID_USE_LIBUUID)
    uuid_t data;
    int parse_status = uuid_parse(s, data);

    if (parse_status != 0)
    {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to parse UUID");
        return 2;
    }

#elif defined(LUA_UUID_USE_APPLE)
    CFUUIDRef data;
    CFUUIDBytes uuid_bytes;
    int is_nil_uuid_str = strcmp("00000000-0000-0000-0000-000000000000", s) == 0;
    CFStringRef strRef = CFStringCreateWithCString(NULL, s, kCFStringEncodingISOLatin1);

    if (strRef == NULL)
    {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to create a CFStringRef");
        return 2;
    }

    data = CFUUIDCreateFromString(NULL, strRef);

    CFRelease(strRef);

    if (data == NULL)
    {
        lua_pushnil(L);
        lua_pushstring(L, "Failed to parse UUID");
        return 2;
    }

    uuid_bytes = CFUUIDGetUUIDBytes(data);
    if ((!is_nil_uuid_str) && LUA_UUID_IS_NULL(uuid_bytes)) {
        CFRelease(data);
        lua_pushnil(L);
        lua_pushstring(L, "Failed to parse UUID");
        return 2;
    }
#endif

    uuid = (LuaUuid *)lua_newuserdata(L, sizeof(LuaUuid));
    if (uuid == NULL)
    {
#if defined(LUA_UUID_USE_WIN32)
        /* do nothing */
#elif defined(LUA_UUID_USE_LIBUUID)
        /* do nothing */
#elif defined(LUA_UUID_USE_APPLE)
        CFRelease(data);
#endif
        lua_pushnil(L);
        lua_pushstring(L, "Failed to create userdata");
        return 2;
    }

    luaL_getmetatable(L, LUA_UUID_METATABLE);
    lua_setmetatable(L, -2);

#if defined(LUA_UUID_USE_WIN32)
    memcpy(&(uuid->data), &data, sizeof(UUID));
#elif defined(LUA_UUID_USE_LIBUUID)
    memcpy(uuid->data, data, sizeof(uuid_t));
#elif defined(LUA_UUID_USE_APPLE)
    memcpy(&(uuid->data), &data, sizeof(CFUUIDRef));
#endif

    lua_pushnil(L);

    return 2;
}

static int lua_uuid_is_nil(lua_State *L)
{
    LuaUuid *uuid = lua_uuid_check(L, 1);
    int res = 0;

#if defined(LUA_UUID_USE_WIN32)
    RPC_STATUS status;
    res = UuidIsNil(&(uuid->data), &status);
#elif defined(LUA_UUID_USE_LIBUUID)
    res = uuid_is_null(uuid->data);
#elif defined(LUA_UUID_USE_APPLE)
    CFUUIDBytes uuid_bytes;
    if (uuid->data == NULL) {
        return luaL_error(L, "Attempt to reuse a closed GUID / UUID instance.");
    }
    uuid_bytes = CFUUIDGetUUIDBytes(uuid->data);
    res = LUA_UUID_IS_NULL(uuid_bytes);
#endif

    lua_pushboolean(L, res);
    return 1;
}

static int lua_uuid_to_string(lua_State *L)
{
    LuaUuid *uuid = lua_uuid_check(L, 1);

#if defined(LUA_UUID_USE_WIN32)
    RPC_CSTR buffer = NULL;
    RPC_STATUS status = UuidToStringA(&(uuid->data), &buffer);

    if (status != RPC_S_OK)
    {
        if (buffer != NULL)
        {
            RpcStringFreeA(&buffer);
        }

        return luaL_error(L, "Failed to convert to string");
    }

    lua_pushstring(L, (const char *)buffer);

    if (buffer != NULL)
    {
        RpcStringFreeA(&buffer);
    }
#elif defined(LUA_UUID_USE_LIBUUID)
    char buffer[LUA_UUID_BUFFER_LEN];
    uuid_unparse(uuid->data, buffer);
    lua_pushstring(L, buffer);
#elif defined(LUA_UUID_USE_APPLE)
    const char *buffer;
    CFStringRef strRef = CFUUIDCreateString(NULL, uuid->data);

    if (strRef == NULL)
    {
        return luaL_error(L, "Failed to create string from UUID");
    }

    buffer = CFStringGetCStringPtr(strRef, kCFStringEncodingISOLatin1);

    if (buffer == NULL)
    {
        CFRelease(strRef);
        return luaL_error(L, "Failed to get C string pointer");
    }

    lua_pushstring(L, buffer);
    CFRelease(strRef);
#endif

    return 1;
}

static int lua_uuid_equal(lua_State *L)
{
    if (lua_isnil(L, 1) || lua_isnil(L, 2))
    {
        lua_pushboolean(L, 0);
    }
    else
    {
        void *ud_left = lua_uuid_testudata(L, 1, LUA_UUID_METATABLE);
        void *ud_right = lua_uuid_testudata(L, 2, LUA_UUID_METATABLE);

        if ((ud_left != NULL) && (ud_right != NULL))
        {
            LuaUuid *left = (LuaUuid *)ud_left;
            LuaUuid *right = (LuaUuid *)ud_right;

#if defined(LUA_UUID_USE_WIN32)
            RPC_STATUS status;
            int is_equal = UuidEqual(&(left->data), &(right->data), &status);
            lua_pushboolean(L, is_equal);

#elif defined(LUA_UUID_USE_LIBUUID)
            int comparison = uuid_compare(left->data, right->data);
            lua_pushboolean(L, comparison == 0);
#elif defined(LUA_UUID_USE_APPLE)

            CFUUIDBytes uuid_bytes_left = CFUUIDGetUUIDBytes(left->data);
            CFUUIDBytes uuid_bytes_right = CFUUIDGetUUIDBytes(right->data);
            int is_equal = uuid_bytes_left.byte0 == uuid_bytes_right.byte0 &&
                uuid_bytes_left.byte1  == uuid_bytes_right.byte1 &&
                uuid_bytes_left.byte2  == uuid_bytes_right.byte2 &&
                uuid_bytes_left.byte3  == uuid_bytes_right.byte3 &&
                uuid_bytes_left.byte4  == uuid_bytes_right.byte4 &&
                uuid_bytes_left.byte5  == uuid_bytes_right.byte5 &&
                uuid_bytes_left.byte6  == uuid_bytes_right.byte6 &&
                uuid_bytes_left.byte7  == uuid_bytes_right.byte7 &&
                uuid_bytes_left.byte8  == uuid_bytes_right.byte8 &&
                uuid_bytes_left.byte9  == uuid_bytes_right.byte9 &&
                uuid_bytes_left.byte10 == uuid_bytes_right.byte10 &&
                uuid_bytes_left.byte11 == uuid_bytes_right.byte11 &&
                uuid_bytes_left.byte12 == uuid_bytes_right.byte12 &&
                uuid_bytes_left.byte13 == uuid_bytes_right.byte13 &&
                uuid_bytes_left.byte14 == uuid_bytes_right.byte14 &&
                uuid_bytes_left.byte15 == uuid_bytes_right.byte15;

            lua_pushboolean(L, is_equal);
#endif
        }
        else
        {
            lua_pushboolean(L, 0);
        }
    }

    return 1;
}

static int lua_uuid_gc(lua_State *L)
{
#if defined(LUA_UUID_USE_WIN32)
    /* do nothing */
    (void)L;
#elif defined(LUA_UUID_USE_LIBUUID)
    /* do nothing */
    (void)L;
#elif defined(LUA_UUID_USE_APPLE)
    LuaUuid *uuid = lua_uuid_check(L, 1);
    if (uuid->data != NULL) {
        CFRelease(uuid->data);
    }
    uuid->data = NULL;
#endif
    return 0;
}

static int lua_uuid_newindex(lua_State *L)
{
    return luaL_error(L, "Read-only object");
}

static const luaL_Reg lua_uuid_public_functions[] = {
    {"new", lua_uuid_new },
    {"parse", lua_uuid_parse },
    {"tryparse", lua_uuid_tryparse },
    { NULL, NULL }
};

static const luaL_Reg lua_uuid_member_functions[] = {
    {"isnil", lua_uuid_is_nil },
    {"__tostring", lua_uuid_to_string },
    {"__eq", lua_uuid_equal },
    {"__gc", lua_uuid_gc },
    { NULL, NULL }
};

LUA_UUID_EXPORT int luaopen_uuid(lua_State *L)
{
    lua_createtable(L, 0, 0);

#if LUA_VERSION_NUM == 501
    luaL_register(L, NULL, lua_uuid_public_functions);
#else
    luaL_setfuncs(L, lua_uuid_public_functions, 0);
#endif

    luaL_newmetatable(L, LUA_UUID_METATABLE);

#if LUA_VERSION_NUM == 501
    luaL_register(L, NULL, lua_uuid_member_functions);
#else
    luaL_setfuncs(L, lua_uuid_member_functions, 0);
#endif

    lua_pushstring(L, "version");
    lua_pushstring(L, LUA_UUID_VERSION);
    lua_settable(L, -3);

    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2);
    lua_settable(L, -3);

    lua_pushstring(L, "__metatable");
    lua_pushboolean(L, 0);
    lua_settable(L, -3);

    lua_pushstring(L, "__newindex");
    lua_pushcfunction(L, lua_uuid_newindex);
    lua_settable(L, -3);

    lua_setmetatable(L, -2);

    return 1;
}
