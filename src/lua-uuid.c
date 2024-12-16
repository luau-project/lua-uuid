#include "lua-uuid.h"

#if defined(LUA_UUID_USE_WIN32)
#include <rpc.h>
#elif defined(LUA_UUID_USE_LIBUUID)
#include <uuid/uuid.h>
#elif defined(LUA_UUID_USE_APPLE)
#include <CoreFoundation/CFUUID.h>
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
    void *ud = lua_newuserdata(L, sizeof(LuaUuid));
    if (ud == NULL)
    {
        luaL_error(L, "Failed to create userdata");
    }

    luaL_getmetatable(L, LUA_UUID_METATABLE);
    lua_setmetatable(L, -2);
    LuaUuid *uuid = (LuaUuid *)ud;

#if defined(LUA_UUID_USE_WIN32)
    RPC_STATUS create_status = UuidCreate(&(uuid->data));
    
    if (create_status != RPC_S_OK)
    {
        luaL_error(L, "Failed to create UUID");
    }
#elif defined(LUA_UUID_USE_LIBUUID)
    uuid_generate(uuid->data);
#elif defined(LUA_UUID_USE_APPLE)
    uuid->data = CFUUIDCreate(NULL);

    if (uuid->data == NULL)
    {
        luaL_error(L, "Failed to create UUID");
    }
#endif

    return 1;
}

static int lua_uuid_parse(lua_State *L)
{
    const char *s = luaL_checkstring(L, 1);

#if defined(LUA_UUID_USE_WIN32)
    UUID data;
    RPC_STATUS parse_status = UuidFromStringA((RPC_CSTR)s, &data);

    if (parse_status != RPC_S_OK)
    {
        luaL_error(L, "Failed to parse UUID");
    }

#elif defined(LUA_UUID_USE_LIBUUID)
    uuid_t data;
    int parse_status = uuid_parse(s, data);

    if (parse_status != 0)
    {
        luaL_error(L, "Failed to parse UUID");
    }

#elif defined(LUA_UUID_USE_APPLE)
    CFStringRef strRef = CFStringCreateWithCString(NULL, s, kCFStringEncodingISOLatin1);

    if (strRef == NULL)
    {
        luaL_error(L, "Failed to create string ref");
    }

    CFUUIDRef data = CFUUIDCreateFromString(NULL, strRef);

    CFRelease(strRef);

    if (data == NULL)
    {
        luaL_error(L, "Failed to parse UUID");
    }

#endif

    void *ud = lua_newuserdata(L, sizeof(LuaUuid));
    if (ud == NULL)
    {
#if defined(LUA_UUID_USE_WIN32)
        /* do nothing */
#elif defined(LUA_UUID_USE_LIBUUID)
        /* do nothing */
#elif defined(LUA_UUID_USE_APPLE)
        CFRelease(data);
#endif

        luaL_error(L, "Failed to create userdata");
    }
    
    luaL_getmetatable(L, LUA_UUID_METATABLE);
    lua_setmetatable(L, -2);
    LuaUuid *uuid = (LuaUuid *)ud;
#if defined(LUA_UUID_USE_WIN32)
    memcpy(&(uuid->data), &data, sizeof(UUID));
#elif defined(LUA_UUID_USE_LIBUUID)
    memcpy(uuid->data, data, sizeof(uuid_t));
#elif defined(LUA_UUID_USE_APPLE)
    memcpy(&(uuid->data), &data, sizeof(CFUUIDRef));
#endif

    return 1;
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
    CFUUIDBytes uuid_bytes = CFUUIDGetUUIDBytes(uuid->data);
    
    res = uuid_bytes.byte0 == 0 &&
        uuid_bytes.byte1 == 0 &&
        uuid_bytes.byte2 == 0 &&
        uuid_bytes.byte3 == 0 &&
        uuid_bytes.byte4 == 0 &&
        uuid_bytes.byte5 == 0 &&
        uuid_bytes.byte6 == 0 &&
        uuid_bytes.byte7 == 0 &&
        uuid_bytes.byte8 == 0 &&
        uuid_bytes.byte9 == 0 &&
        uuid_bytes.byte10 == 0 &&
        uuid_bytes.byte11 == 0 &&
        uuid_bytes.byte12 == 0 &&
        uuid_bytes.byte13 == 0 &&
        uuid_bytes.byte14 == 0 &&
        uuid_bytes.byte15 == 0;
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

        luaL_error(L, "Failed to convert to string");
    }

    lua_pushstring(L, (const char *)buffer);
    
    if (buffer != NULL)
    {
        RpcStringFreeA(&buffer);
    }
#elif defined(LUA_UUID_USE_LIBUUID)
    char buffer[32];
    uuid_unparse(uuid->data, buffer);
    lua_pushstring(L, buffer);
#elif defined(LUA_UUID_USE_APPLE)
    CFStringRef strRef = CFUUIDCreateString(NULL, uuid->data);

    if (strRef == NULL)
    {
        luaL_error(L, "Failed to create string from UUID");
    }

    const char *buffer = CFStringGetCStringPtr(strRef, kCFStringEncodingISOLatin1);
    
    if (buffer == NULL)
    {
        CFRelease(strRef);
        luaL_error(L, "Failed to get C string pointer");
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

        if (ud_left != NULL && ud_right != NULL)
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
                uuid_bytes_left.byte1 == uuid_bytes_right.byte1 &&
                uuid_bytes_left.byte2 == uuid_bytes_right.byte2 &&
                uuid_bytes_left.byte3 == uuid_bytes_right.byte3 &&
                uuid_bytes_left.byte4 == uuid_bytes_right.byte4 &&
                uuid_bytes_left.byte5 == uuid_bytes_right.byte5 &&
                uuid_bytes_left.byte6 == uuid_bytes_right.byte6 &&
                uuid_bytes_left.byte7 == uuid_bytes_right.byte7 &&
                uuid_bytes_left.byte8 == uuid_bytes_right.byte8 &&
                uuid_bytes_left.byte9 == uuid_bytes_right.byte9 &&
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
#elif defined(LUA_UUID_USE_LIBUUID)
    /* do nothing */
#elif defined(LUA_UUID_USE_APPLE)
    LuaUuid *uuid = lua_uuid_check(L, 1);
    CFRelease(uuid->data);
#endif
    return 0;
}

static int lua_uuid_newindex(lua_State *L)
{
    luaL_error(L, "Read-only object");
    return 1;
}

static const luaL_Reg lua_uuid_public_functions[] = {
    {"new", lua_uuid_new },
    {"parse", lua_uuid_parse },
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
