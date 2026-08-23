## lua-uuid v0.0.8

* Moving back to the old mode listing platforms on ```build``` and ```external_dependencies``` tables for platform overrides. At the moment, platform overrides merge tables rather than selecting the appropriate value.

## lua-uuid v0.0.7

* Allowed any Unix-like distribution to build and install ```lua-uuid```, depending on the system-provided development package for ```libuuid```;
* Added a CI job to build and test on Cygwin;
* Now, as a Unix-like distribution, Cygwin depends on the package ```libuuid-devel```.

## lua-uuid v0.0.6

> [!IMPORTANT]
> 
> This is a bug-fix release that fixed a buffer overflow in the binding of ```libuuid```. Users running older versions must upgrade as soon as possible to avoid potential exploits.

## lua-uuid v0.0.5

* Adhering to C89;
* Added CI job to make sure that this library conforms to C89;
* Added another CI job to assert that this library builds fine as C++ code;
* Linting rockspecs on CI;
* Minor changes on the makefile for macOS / iOS;
* The naming format for the published rockspecs changed from ```vX.Y.Z-0``` to ```vX.Y.Z-1```.

## lua-uuid v0.0.4

* Added support for BSD (e.g: FreeBSD, NetBSD, OpenBSD and DragonFly);
* Moved ```#include <lua.h>``` and ```LUA_UUID_EXPORT``` macro definition to outside of ```__cplusplus``` declarations on ```lua-uuid.h```.

## lua-uuid v0.0.3

* Changed to throw error when ```lua_newuserdata``` returns ```NULL```;
* Added macro ```LUA_UUID_BUILD_SHARED``` to ```CFLAGS_EXTRA``` on macos;
* Changed ```luajit-master``` to ```luajit``` on CI when testing for ```LuaJIT```;
* Added print statements on [tostring.lua](./samples/tostring.lua) sample;
* Removed build / testing from CI for x86 packages on MSYS2;
* Added documentation for static, instance and metamethods to the README.

## lua-uuid v0.0.2

* Fixed syntax issue in the rockspec lua-uuid-0.0.1-0.rockspec

## lua-uuid v0.0.1

* Initial release.