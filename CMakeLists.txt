#=================================================================================#
# LICENSE (MIT)                                                                   #
#=================================================================================#
#                                                                                 #
# The MIT License (MIT)                                                           #
#                                                                                 #
# Copyright (c) 2024 - 2026 luau-project https://github.com/luau-project/lua-uuid #
#                                                                                 #
# Permission is hereby granted, free of charge, to any person obtaining a copy    #
# of this software and associated documentation files (the "Software"), to deal   #
# in the Software without restriction, including without limitation the rights    #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell       #
# copies of the Software, and to permit persons to whom the Software is           #
# furnished to do so, subject to the following conditions:                        #
#                                                                                 #
# The above copyright notice and this permission notice shall be included in all  #
# copies or substantial portions of the Software.                                 #
#                                                                                 #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR      #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   #
# SOFTWARE.                                                                       #
#                                                                                 #
#=================================================================================#

##################################
# Main arguments:                #
##################################
#                                #
# LUA_VERSION (STRING)           #
#   Description:                 #
#     The version of PUC-Lua.    #
#   Remarks:                     #
#     Do NOT set this field for  #
#     LuaJIT / OpenResty.        #
#   e.g.:                        #
#     * 5.1                      #
#     * 5.2.4                    #
#     * 5.4.8                    #
#   Default value: UNDEFINED     #
#                                #
# LUA_UUID_ENABLE_TESTS (ON/OFF) #
#   Description:                 #
#     Run tests.                 #
#   Default value: ON            #
#                                #
# INSTALL_CMOD (PATH)            #
#   Description:                 #
#     Relative path where Lua    #
#     finds modules written      #
#     in C.                      #
#   e.g.:                        #
#     * lib/lua/5.4              #
#     * lib/x86_64-linux-gnu     #
#     * bin                      #
#   Default value: UNDEFINED     #
#                                #
##################################

CMAKE_MINIMUM_REQUIRED(VERSION 3.14)

PROJECT(lua-uuid
    VERSION 0.1.0
    LANGUAGES C
)

SET(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type.")
OPTION(LUA_UUID_ENABLE_TESTS "Enable testing `lua-uuid'" ON)

IF (LUA_UUID_ENABLE_TESTS)
    ENABLE_TESTING()
ENDIF()

SET(_SAMPLES_ISNIL "${PROJECT_SOURCE_DIR}/samples/isnil.lua")
SET(_SAMPLES_NEW "${PROJECT_SOURCE_DIR}/samples/new.lua")
SET(_SAMPLES_PARSE "${PROJECT_SOURCE_DIR}/samples/parse.lua")
SET(_SAMPLES_TOSTRING "${PROJECT_SOURCE_DIR}/samples/tostring.lua")
SET(_SAMPLES_TRYPARSE "${PROJECT_SOURCE_DIR}/samples/tryparse.lua")
SET(_SAMPLES_VERSION "${PROJECT_SOURCE_DIR}/samples/version.lua")

SET(_LUA_UUID_TEST_FILES
    ${_SAMPLES_ISNIL}
    ${_SAMPLES_NEW}
    ${_SAMPLES_PARSE}
    ${_SAMPLES_TOSTRING}
    ${_SAMPLES_TRYPARSE}
    ${_SAMPLES_VERSION}
)

IF (APPLE)
    ADD_LIBRARY(lua-uuid MODULE)
ELSE()
    ADD_LIBRARY(lua-uuid SHARED)
ENDIF()

TARGET_SOURCES(lua-uuid
    PRIVATE
    "${PROJECT_SOURCE_DIR}/src/lua-uuid.c"
    "${PROJECT_SOURCE_DIR}/src/lua-uuid.h"
)
TARGET_INCLUDE_DIRECTORIES(lua-uuid PRIVATE src)

SET_TARGET_PROPERTIES(lua-uuid
    PROPERTIES
    PREFIX ""
)

TARGET_COMPILE_DEFINITIONS(lua-uuid PRIVATE "LUA_UUID_BUILD_SHARED")

IF (WIN32)
    TARGET_COMPILE_DEFINITIONS(lua-uuid PRIVATE "LUA_UUID_USE_WIN32")
    TARGET_LINK_LIBRARIES(lua-uuid PRIVATE "rpcrt4")
ELSEIF (APPLE)
    TARGET_COMPILE_DEFINITIONS(lua-uuid PRIVATE "LUA_UUID_USE_APPLE")
    TARGET_LINK_OPTIONS(lua-uuid
        PRIVATE
        "LINKER:-bundle"
        "LINKER:-undefined,dynamic_lookup"
        "LINKER:-all_load"
        "LINKER:-framework,CoreFoundation"
    )
    SET_TARGET_PROPERTIES(lua-uuid
        PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        SUFFIX ".so"
    )
ELSE()
    TARGET_COMPILE_DEFINITIONS(lua-uuid PRIVATE "LUA_UUID_USE_LIBUUID")

    SET_TARGET_PROPERTIES(lua-uuid
        PROPERTIES
        POSITION_INDEPENDENT_CODE ON
    )

    FIND_LIBRARY(LIBUUID uuid OPTIONAL)

    IF (LIBUUID)
        MESSAGE(STATUS "Found `libuuid' at `${LIBUUID}'")
        TARGET_LINK_LIBRARIES(lua-uuid PRIVATE ${LIBUUID})
    ELSE()
        MESSAGE(FATAL_ERROR "Failed to find the `libuuid'. Please, install the development package for `libuuid'")
    ENDIF()

    FIND_PATH(LIBUUID_INCDIR
        NAMES "uuid/uuid.h"
    )
    IF (LIBUUID_INCDIR)
        IF (EXISTS "${LIBUUID_INCDIR}/uuid/uuid.h")
            MESSAGE(STATUS "Found `uuid.h' at `${LIBUUID_INCDIR}/uuid'")
            TARGET_INCLUDE_DIRECTORIES(lua-uuid PRIVATE ${LIBUUID_INCDIR})
        ELSE()
            MESSAGE(FATAL_ERROR "Failed to find the header `uuid.h' at `${LIBUUID_INCDIR}/uuid'. Please, install the development package for `libuuid'")
        ENDIF()
    ELSE()
        MESSAGE(FATAL_ERROR "Failed to find the header `uuid.h'. Please, install the development package for `libuuid'")
    ENDIF()
ENDIF()

FIND_PACKAGE(Lua ${LUA_VERSION} QUIET)

IF (LUA_FOUND)
    MESSAGE(STATUS "Found Lua headers at `${LUA_INCLUDE_DIR}'")
    TARGET_INCLUDE_DIRECTORIES(lua-uuid PRIVATE ${LUA_INCLUDE_DIR})
    IF (WIN32)
        MESSAGE(STATUS "Found the Lua libraries at `${LUA_LIBRARIES}'")
        TARGET_LINK_LIBRARIES(lua-uuid PRIVATE ${LUA_LIBRARIES})
    ENDIF()

    IF (LUA_UUID_ENABLE_TESTS)
        FIND_PROGRAM(LUA_PROG
            NAMES
                "lua${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}"
                "lua${LUA_VERSION_MAJOR}${LUA_VERSION_MINOR}"
                "lua-${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}"
                "lua-${LUA_VERSION_MAJOR}${LUA_VERSION_MINOR}"
                "lua"
            HINTS ENV LUA_DIR
            OPTIONAL
        )

        IF (NOT LUA_PROG)
            MESSAGE(FATAL_ERROR "Failed to find Lua ${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}")
        ENDIF()

        execute_process(
            COMMAND ${LUA_PROG} "-v"
            OUTPUT_VARIABLE LUA_VERSION_CONTENT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        IF (NOT LUA_VERSION_CONTENT MATCHES "^Lua .* PUC-Rio")
            MESSAGE(FATAL_ERROR "Failed to find a working Lua interpreter")
        ENDIF()

        execute_process(
            COMMAND ${LUA_PROG} "-e" "print(_VERSION:sub(5))"
            OUTPUT_VARIABLE LUA_ABI_CONTENT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        IF (NOT LUA_ABI_CONTENT STREQUAL "${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}")
            MESSAGE(FATAL_ERROR "Failed to find a working Lua interpreter")
        ENDIF()
    ENDIF()
ELSE()
    FOREACH(LUAJIT_SUFFIX "-2.1" "" "-2.0")
        FIND_PATH(LUA_INCLUDE_DIR
            NAMES "luajit.h"
            HINTS ENV LUA_DIR
            PATH_SUFFIXES "luajit${LUAJIT_SUFFIX}"
        )

        IF (LUA_INCLUDE_DIR AND
            EXISTS "${LUA_INCLUDE_DIR}/lua.h" AND
            EXISTS "${LUA_INCLUDE_DIR}/luaconf.h" AND
            EXISTS "${LUA_INCLUDE_DIR}/lualib.h" AND
            EXISTS "${LUA_INCLUDE_DIR}/lauxlib.h" AND
            EXISTS "${LUA_INCLUDE_DIR}/lua.hpp" AND
            EXISTS "${LUA_INCLUDE_DIR}/luajit.h")
            MESSAGE(STATUS "Found LuaJIT headers at `${LUA_INCLUDE_DIR}'")
            BREAK()
        ENDIF()
    ENDFOREACH()

    IF (NOT LUA_INCLUDE_DIR)
        MESSAGE(FATAL_ERROR "Failed to find Lua or LuaJIT")
    ENDIF()

    TARGET_INCLUDE_DIRECTORIES(lua-uuid PRIVATE ${LUA_INCLUDE_DIR})

    IF (WIN32)
        IF (MINGW)
            FIND_FILE(LUA_LIBRARIES
                NAMES "lua51.dll"
                HINTS ENV LUA_DIR
                OPTIONAL
            )
        ELSE()
            FIND_LIBRARY(LUA_LIBRARIES
                NAMES "lua51"
                HINTS ENV LUA_DIR
                OPTIONAL
            )
        ENDIF()

        IF (LUA_LIBRARIES)
            MESSAGE(STATUS "Found import libraries for LuaJIT at `${LUA_LIBRARIES}'")
            TARGET_LINK_LIBRARIES(lua-uuid PRIVATE ${LUA_LIBRARIES})
        ELSE()
            MESSAGE(FATAL_ERROR "Failed to find import libraries for LuaJIT")
        ENDIF()

    ENDIF()

    IF (LUA_UUID_ENABLE_TESTS)
        FIND_PROGRAM(LUA_PROG
            NAMES "luajit" "lua"
            HINTS ENV LUA_DIR
            OPTIONAL
        )

        IF (NOT LUA_PROG)
            MESSAGE(FATAL_ERROR "Failed to find LuaJIT")
        ENDIF()

        execute_process(
            COMMAND ${LUA_PROG} "-v"
            OUTPUT_VARIABLE LUAJIT_VERSION_CONTENT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        IF (NOT LUAJIT_VERSION_CONTENT MATCHES "^LuaJIT .* Mike Pall")
            MESSAGE(FATAL_ERROR "Failed to find a working LuaJIT interpreter")
        ENDIF()

        execute_process(
            COMMAND ${LUA_PROG} "-e" "print(_VERSION:sub(5))"
            OUTPUT_VARIABLE LUAJIT_ABI_CONTENT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        IF (NOT LUAJIT_ABI_CONTENT STREQUAL "5.1")
            MESSAGE(FATAL_ERROR "Failed to find a working LuaJIT interpreter")
        ENDIF()
    ENDIF()
ENDIF()

IF (LUAJIT_ABI_CONTENT STREQUAL "5.1")
    SET(LUA_VERSION_MAJOR "5")
    SET(LUA_VERSION_MINOR "1")
ENDIF()
SET(_LUA_ABI "${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}")

SET(_INSTALL_KIND)
SET(_INSTALL_CMOD)

IF (INSTALL_CMOD)
    IF (IS_ABSOLUTE "${INSTALL_CMOD}")
        MESSAGE(FATAL_ERROR "`INSTALL_CMOD' must be a relative path")
    ENDIF()

    SET(_INSTALL_CMOD "${INSTALL_CMOD}")

    IF (WIN32)
        SET(_INSTALL_KIND "RUNTIME")

        # INSTALL(TARGETS lua-uuid
        #     RUNTIME DESTINATION "${INSTALL_CMOD}"
        # )
    ELSE()
        SET(_INSTALL_KIND "LIBRARY")

        # INSTALL(TARGETS lua-uuid
        #     LIBRARY DESTINATION "${INSTALL_CMOD}"
        # )
    ENDIF()
ELSE()

    include(GNUInstallDirs)

    IF (MSYS OR CYGWIN)
        SET(_INSTALL_KIND "RUNTIME")
        SET(_INSTALL_CMOD "${CMAKE_INSTALL_LIBDIR}/lua/${_LUA_ABI}")

        # INSTALL(TARGETS lua-uuid
        #     RUNTIME DESTINATION "${CMAKE_INSTALL_LIBDIR}/lua/${_LUA_ABI}"
        # )
    ELSEIF (WIN32)
        SET(_INSTALL_KIND "RUNTIME")
        IF ("${_LUA_ABI}" STREQUAL "5.1" OR "${_LUA_ABI}" STREQUAL "5.2")
            SET(_INSTALL_CMOD "${CMAKE_INSTALL_BINDIR}")

            # INSTALL(TARGETS lua-uuid
            #     RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
            # )
        ELSE()
            SET(_INSTALL_CMOD "${CMAKE_INSTALL_LIBDIR}/lua/${_LUA_ABI}")

            # INSTALL(TARGETS lua-uuid
            #     RUNTIME DESTINATION "${CMAKE_INSTALL_LIBDIR}/lua/${_LUA_ABI}"
            # )
        ENDIF()
    ELSE()
        SET(_INSTALL_KIND "LIBRARY")
        SET(_INSTALL_CMOD "${CMAKE_INSTALL_LIBDIR}/lua/${_LUA_ABI}")

        # INSTALL(TARGETS lua-uuid
        #     LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}/lua/${_LUA_ABI}"
        # )
    ENDIF()
ENDIF()

INSTALL(TARGETS lua-uuid
    "${_INSTALL_KIND}" DESTINATION "${_INSTALL_CMOD}"
)

IF (LUA_UUID_ENABLE_TESTS)
    FOREACH (_TEST_FILE ${_LUA_UUID_TEST_FILES})
        GET_FILENAME_COMPONENT(_BASENAME ${_TEST_FILE} NAME)
        ADD_TEST(NAME ${_BASENAME}
            COMMAND ${LUA_PROG} ${_TEST_FILE}
        )
        IF (WIN32)
            SET_TESTS_PROPERTIES(${_BASENAME}
                PROPERTIES
                ENVIRONMENT "LUA_CPATH=${CMAKE_CURRENT_BINARY_DIR}\\?.dll\;\;"
            )
        ELSE()
            SET_TESTS_PROPERTIES(${_BASENAME}
                PROPERTIES
                ENVIRONMENT "LUA_CPATH=${CMAKE_CURRENT_BINARY_DIR}/?.so\;\;"
            )
        ENDIF()
    ENDFOREACH()
ENDIF()

MESSAGE(STATUS " ")
MESSAGE(STATUS " Configuration summary:")
MESSAGE(STATUS "   Lua")
MESSAGE(STATUS "     Version: ........... ${_LUA_ABI}")
MESSAGE(STATUS "     Include dir: ....... ${LUA_INCLUDE_DIR}")
IF (WIN32)
MESSAGE(STATUS "     Libraries: ......... ${LUA_LIBRARIES}")
ENDIF()
IF (LUA_UUID_ENABLE_TESTS)
MESSAGE(STATUS "     Interpreter: ....... ${LUA_PROG}")
ENDIF()
IF (NOT (WIN32 OR APPLE))
MESSAGE(STATUS "   libuuid")
MESSAGE(STATUS "     Include dir: ....... ${LIBUUID_INCDIR}")
MESSAGE(STATUS "     Libraries: ......... ${LIBUUID}")
MESSAGE(STATUS " ")
MESSAGE(STATUS " Install")
MESSAGE(STATUS "   Prefix: .............. ${CMAKE_INSTALL_PREFIX}")
MESSAGE(STATUS "   lua-uuid dir: ........ ${CMAKE_INSTALL_PREFIX}/${_INSTALL_CMOD}")
ENDIF()
MESSAGE(STATUS " ")