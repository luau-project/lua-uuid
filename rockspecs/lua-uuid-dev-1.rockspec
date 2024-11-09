package = "lua-uuid"
version = "dev-1"

source = {
    url = "git://github.com/luau-project/lua-uuid.git"
}

description = {
    homepage = "https://github.com/luau-project/lua-uuid",
    summary = [[Lightweight, native GUID / UUID library for Lua]],
    license = "MIT"
}

supported_platforms = { "linux", "win32", "mingw" }

dependencies = {
    "lua >= 5.1"
}

external_dependencies = {
    platforms = {
        linux = {
            ["UUID"] = {
                header = "uuid/uuid.h"
            }
        }
    }
}

build = {
    type = "builtin",
    platforms = {
        win32 = {
            modules = {
                ["lua-uuid"] = {
                    sources = { "src/lua-uuid.c" },
                    libraries = { "rpcrt4" },
                    defines = { "LUA_UUID_BUILD_SHARED", "LUA_UUID_USE_WIN32" },
                    incdirs = { "src" },
                    libdirs = {}
                }
            }
        },
        mingw = {
            modules = {
                ["lua-uuid"] = {
                    sources = { "src/lua-uuid.c" },
                    libraries = { "rpcrt4" },
                    defines = { "LUA_UUID_BUILD_SHARED", "LUA_UUID_USE_WIN32" },
                    incdirs = { "src" },
                    libdirs = {}
                }
            }
        },
        linux = {
            modules = {
                ["lua-uuid"] = {
                    sources = { "src/lua-uuid.c" },
                    libraries = { "uuid" },
                    defines = { "LUA_UUID_BUILD_SHARED", "LUA_UUID_USE_LIBUUID" },
                    incdirs = { "src", "$(UUID_INCDIR)" },
                    libdirs = { "$(UUID_LIBDIR)" }
                }
            }
        }
    }
}
