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
#     The version of Lua.        #
#   Examples:                    #
#     * luajit                   #
#     * 5.1                      #
#     * 5.1.5                    #
#     * 5.2                      #
#     * 5.2.4                    #
#     * 5.3                      #
#     * 5.3.6                    #
#     * 5.4                      #
#     * 5.4.9                    #
#     * 5.5                      #
#     * 5.5.1                    #
#   Default value: (UNDEFINED)   #
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
#   Examples:                    #
#     * lib/lua/5.4              #
#     * lib/x86_64-linux-gnu     #
#     * bin                      #
#   Default value: (UNDEFINED)   #
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

SET(_SAMPLES_DIR "${PROJECT_SOURCE_DIR}/samples")
SET(_SAMPLES_ISNIL "${_SAMPLES_DIR}/isnil.lua")
SET(_SAMPLES_NEW "${_SAMPLES_DIR}/new.lua")
SET(_SAMPLES_PARSE "${_SAMPLES_DIR}/parse.lua")
SET(_SAMPLES_TOSTRING "${_SAMPLES_DIR}/tostring.lua")
SET(_SAMPLES_TRYPARSE "${_SAMPLES_DIR}/tryparse.lua")
SET(_SAMPLES_VERSION "${_SAMPLES_DIR}/version.lua")

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

SET(_SRC_DIR "${PROJECT_SOURCE_DIR}/src")

TARGET_SOURCES(lua-uuid
    PRIVATE
    "${_SRC_DIR}/lua-uuid.c"
    "${_SRC_DIR}/lua-uuid.h"
)
TARGET_INCLUDE_DIRECTORIES(lua-uuid PRIVATE "${_SRC_DIR}")

SET_TARGET_PROPERTIES(lua-uuid
    PROPERTIES
    PREFIX ""
)

TARGET_COMPILE_DEFINITIONS(lua-uuid PRIVATE "LUA_UUID_BUILD_SHARED")

IF (WIN32)
    TARGET_SOURCES(lua-uuid PRIVATE "${PROJECT_SOURCE_DIR}/lua-uuid.def")
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

    FIND_LIBRARY(LIBUUID_LIBRARIES
        NAMES "uuid"
        HINTS ENV LIBUUID_DIR
        OPTIONAL
    )

    IF (LIBUUID_LIBRARIES)
        MESSAGE(STATUS "Found `libuuid' at `${LIBUUID_LIBRARIES}'")
        TARGET_LINK_LIBRARIES(lua-uuid PRIVATE ${LIBUUID_LIBRARIES})
    ELSE()
        MESSAGE(FATAL_ERROR "Failed to find the `libuuid'. Please, install the development package for `libuuid'")
    ENDIF()

    FIND_PATH(LIBUUID_INCLUDE_DIR
        NAMES "uuid/uuid.h"
        HINTS ENV LIBUUID_DIR
        OPTIONAL
    )

    IF (LIBUUID_INCLUDE_DIR)
        IF (EXISTS "${LIBUUID_INCLUDE_DIR}/uuid/uuid.h")
            MESSAGE(STATUS "Found `uuid.h' at `${LIBUUID_INCLUDE_DIR}/uuid'")
            TARGET_INCLUDE_DIRECTORIES(lua-uuid PRIVATE ${LIBUUID_INCLUDE_DIR})
        ELSE()
            MESSAGE(FATAL_ERROR "Failed to find the header `uuid.h' at `${LIBUUID_INCLUDE_DIR}/uuid'. Please, install the development package for `libuuid'")
        ENDIF()
    ELSE()
        MESSAGE(FATAL_ERROR "Failed to find the header `uuid.h'. Please, install the development package for `libuuid'")
    ENDIF()
ENDIF()

# Helper function to find LuaJIT
FUNCTION(_FIND_LUAJIT ERROR_MSG_VAR)
    FOREACH(LUAJIT_SUFFIX "-2.1" "" "-2.0")
        FIND_PATH(_LUAJIT_INCLUDE_DIR
            NAMES "luajit.h"
            HINTS ENV LUAJIT_DIR
                  ENV LUA_DIR
            PATH_SUFFIXES "luajit${LUAJIT_SUFFIX}"
        )

        IF (_LUAJIT_INCLUDE_DIR AND
            EXISTS "${_LUAJIT_INCLUDE_DIR}/lua.h" AND
            EXISTS "${_LUAJIT_INCLUDE_DIR}/luaconf.h" AND
            EXISTS "${_LUAJIT_INCLUDE_DIR}/lualib.h" AND
            EXISTS "${_LUAJIT_INCLUDE_DIR}/lauxlib.h" AND
            EXISTS "${_LUAJIT_INCLUDE_DIR}/lua.hpp" AND
            EXISTS "${_LUAJIT_INCLUDE_DIR}/luajit.h")
            BREAK()
        ELSE()
            UNSET(_LUAJIT_INCLUDE_DIR)
        ENDIF()
    ENDFOREACH()

    IF (NOT _LUAJIT_INCLUDE_DIR)
        IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
            SET(${ERROR_MSG_VAR} "Failed to find LuaJIT headers" PARENT_SCOPE)
        ENDIF()
        SET(LUAJIT_FOUND OFF PARENT_SCOPE)
        IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
            MARK_AS_ADVANCED(
                LUAJIT_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUAJIT_INTERPRETER
                LUAJIT_INCLUDE_DIR
                LUAJIT_LIBRARIES
                ${ERROR_MSG_VAR}
            )
        ELSE()
            MARK_AS_ADVANCED(
                LUAJIT_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUAJIT_INTERPRETER
                LUAJIT_INCLUDE_DIR
                LUAJIT_LIBRARIES
            )
        ENDIF()
        RETURN()
    ENDIF()

    IF (WIN32)
        IF (MINGW)
            FIND_FILE(_LUAJIT_LIBRARIES
                NAMES "lua51.dll"
                HINTS ENV LUAJIT_DIR
                      ENV LUA_DIR
                OPTIONAL
            )
        ELSE()
            FIND_LIBRARY(_LUAJIT_LIBRARIES
                NAMES "lua51"
                HINTS ENV LUAJIT_DIR
                      ENV LUA_DIR
                OPTIONAL
            )
        ENDIF()

        IF (NOT _LUAJIT_LIBRARIES)
            IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
                SET(${ERROR_MSG_VAR} "Failed to find import libraries for LuaJIT" PARENT_SCOPE)
            ENDIF()
            SET(LUAJIT_FOUND OFF PARENT_SCOPE)
            IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
                MARK_AS_ADVANCED(
                    LUAJIT_FOUND
                    LUA_VERSION_MAJOR
                    LUA_VERSION_MINOR
                    LUAJIT_INTERPRETER
                    LUAJIT_INCLUDE_DIR
                    LUAJIT_LIBRARIES
                    ${ERROR_MSG_VAR}
                )
            ELSE()
                MARK_AS_ADVANCED(
                    LUAJIT_FOUND
                    LUA_VERSION_MAJOR
                    LUA_VERSION_MINOR
                    LUAJIT_INTERPRETER
                    LUAJIT_INCLUDE_DIR
                    LUAJIT_LIBRARIES
                )
            ENDIF()
            RETURN()
        ENDIF()
    ELSE()
        FIND_LIBRARY(_LUAJIT_LIBRARIES
            NAMES "luajit-5.1" "luajit"
            HINTS ENV LUAJIT_DIR
                  ENV LUA_DIR
            OPTIONAL
        )

        IF (NOT _LUAJIT_LIBRARIES)
            IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
                SET(${ERROR_MSG_VAR} "Failed to find LuaJIT library" PARENT_SCOPE)
            ENDIF()
            SET(LUAJIT_FOUND OFF PARENT_SCOPE)
            IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
                MARK_AS_ADVANCED(
                    LUAJIT_FOUND
                    LUA_VERSION_MAJOR
                    LUA_VERSION_MINOR
                    LUAJIT_INTERPRETER
                    LUAJIT_INCLUDE_DIR
                    LUAJIT_LIBRARIES
                    ${ERROR_MSG_VAR}
                )
            ELSE()
                MARK_AS_ADVANCED(
                    LUAJIT_FOUND
                    LUA_VERSION_MAJOR
                    LUA_VERSION_MINOR
                    LUAJIT_INTERPRETER
                    LUAJIT_INCLUDE_DIR
                    LUAJIT_LIBRARIES
                )
            ENDIF()
            RETURN()
        ENDIF()
    ENDIF()

    FIND_PROGRAM(_LUAJIT_INTERPRETER
        NAMES "luajit" "lua" "lua5.1" "lua51" "lua-5.1" "lua-51"
        HINTS ENV LUAJIT_DIR
              ENV LUA_DIR
        OPTIONAL
    )

    IF (NOT _LUAJIT_INTERPRETER)
        IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
            SET(${ERROR_MSG_VAR} "Failed to find LuaJIT" PARENT_SCOPE)
        ENDIF()
        SET(LUAJIT_FOUND OFF PARENT_SCOPE)
        IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
            MARK_AS_ADVANCED(
                LUAJIT_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUAJIT_INTERPRETER
                LUAJIT_INCLUDE_DIR
                LUAJIT_LIBRARIES
                ${ERROR_MSG_VAR}
            )
        ELSE()
            MARK_AS_ADVANCED(
                LUAJIT_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUAJIT_INTERPRETER
                LUAJIT_INCLUDE_DIR
                LUAJIT_LIBRARIES
            )
        ENDIF()
        RETURN()
    ENDIF()

    EXECUTE_PROCESS(
        COMMAND ${_LUAJIT_INTERPRETER} "-v"
        OUTPUT_VARIABLE _LUAJIT_VERSION_CONTENT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    IF (NOT _LUAJIT_VERSION_CONTENT MATCHES "^LuaJIT .* Mike Pall")
        IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
            SET(${ERROR_MSG_VAR} "Failed to find a working LuaJIT interpreter" PARENT_SCOPE)
        ENDIF()
        SET(LUAJIT_FOUND OFF PARENT_SCOPE)
        IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
            MARK_AS_ADVANCED(
                LUAJIT_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUAJIT_INTERPRETER
                LUAJIT_INCLUDE_DIR
                LUAJIT_LIBRARIES
                ${ERROR_MSG_VAR}
            )
        ELSE()
            MARK_AS_ADVANCED(
                LUAJIT_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUAJIT_INTERPRETER
                LUAJIT_INCLUDE_DIR
                LUAJIT_LIBRARIES
            )
        ENDIF()
        RETURN()
    ENDIF()

    EXECUTE_PROCESS(
        COMMAND ${_LUAJIT_INTERPRETER} "-e" "print(_VERSION:sub(5))"
        OUTPUT_VARIABLE _LUAJIT_ABI_CONTENT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    IF (NOT _LUAJIT_ABI_CONTENT STREQUAL "5.1")
        IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
            SET(${ERROR_MSG_VAR} "Failed to find a working LuaJIT interpreter" PARENT_SCOPE)
        ENDIF()
        SET(LUAJIT_FOUND OFF PARENT_SCOPE)
        IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
            MARK_AS_ADVANCED(
                LUAJIT_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUAJIT_INTERPRETER
                LUAJIT_INCLUDE_DIR
                LUAJIT_LIBRARIES
                ${ERROR_MSG_VAR}
            )
        ELSE()
            MARK_AS_ADVANCED(
                LUAJIT_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUAJIT_INTERPRETER
                LUAJIT_INCLUDE_DIR
                LUAJIT_LIBRARIES
            )
        ENDIF()
        RETURN()
    ENDIF()

    SET(LUAJIT_FOUND ON PARENT_SCOPE)
    SET(LUA_VERSION_MAJOR "5" PARENT_SCOPE)
    SET(LUA_VERSION_MINOR "1" PARENT_SCOPE)
    SET(LUAJIT_INTERPRETER "${_LUAJIT_INTERPRETER}" PARENT_SCOPE)
    SET(LUAJIT_INCLUDE_DIR "${_LUAJIT_INCLUDE_DIR}" PARENT_SCOPE)
    SET(LUAJIT_LIBRARIES "${_LUAJIT_LIBRARIES}" PARENT_SCOPE)
    IF (${ERROR_MSG_VAR})
        UNSET(${ERROR_MSG_VAR} PARENT_SCOPE)
    ENDIF()

    IF (NOT "${ERROR_MSG_VAR}" STREQUAL "")
        MARK_AS_ADVANCED(
            LUAJIT_FOUND
            LUA_VERSION_MAJOR
            LUA_VERSION_MINOR
            LUAJIT_INTERPRETER
            LUAJIT_INCLUDE_DIR
            LUAJIT_LIBRARIES
            ${ERROR_MSG_VAR}
        )
    ELSE()
        MARK_AS_ADVANCED(
            LUAJIT_FOUND
            LUA_VERSION_MAJOR
            LUA_VERSION_MINOR
            LUAJIT_INTERPRETER
            LUAJIT_INCLUDE_DIR
            LUAJIT_LIBRARIES
        )
    ENDIF()
ENDFUNCTION()

# Macro used in multiple locations
# to setup lua-uuid for LuaJIT
MACRO(_SETUP_LUA_UUID_FOR_LUAJIT)
    _FIND_LUAJIT(ERROR_MSG)

    IF (NOT LUAJIT_FOUND)
        MESSAGE(FATAL_ERROR ${ERROR_MSG})
    ENDIF()

    SET(LUA_INCLUDE_DIR "${LUAJIT_INCLUDE_DIR}")
    SET(LUA_LIBRARIES "${LUAJIT_LIBRARIES}")
    SET(_LUA_INTERPRETER "${LUAJIT_INTERPRETER}")

    TARGET_INCLUDE_DIRECTORIES(lua-uuid PRIVATE ${LUA_INCLUDE_DIR})
    IF (WIN32)
        TARGET_LINK_LIBRARIES(lua-uuid PRIVATE ${LUA_LIBRARIES})
    ENDIF()
ENDMACRO()

IF ("${LUA_VERSION}" MATCHES "^luajit")
    _SETUP_LUA_UUID_FOR_LUAJIT()
ELSE()
    IF (DEFINED LUA_VERSION)
        FIND_PACKAGE(Lua "${LUA_VERSION}" EXACT QUIET)
    ELSE()
        FIND_PACKAGE(Lua QUIET)
    ENDIF()

    IF (LUA_FOUND)
        MESSAGE(STATUS "Found Lua headers at `${LUA_INCLUDE_DIR}'")
        TARGET_INCLUDE_DIRECTORIES(lua-uuid PRIVATE ${LUA_INCLUDE_DIR})
        IF (WIN32)
            MESSAGE(STATUS "Found the Lua libraries at `${LUA_LIBRARIES}'")
            TARGET_LINK_LIBRARIES(lua-uuid PRIVATE ${LUA_LIBRARIES})
        ENDIF()

        IF (LUA_UUID_ENABLE_TESTS)
            FIND_PROGRAM(_LUA_INTERPRETER
                NAMES
                    "lua${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}"
                    "lua${LUA_VERSION_MAJOR}${LUA_VERSION_MINOR}"
                    "lua-${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}"
                    "lua-${LUA_VERSION_MAJOR}${LUA_VERSION_MINOR}"
                    "lua"
                HINTS ENV LUA_DIR
                OPTIONAL
            )

            IF (NOT _LUA_INTERPRETER)
                MESSAGE(FATAL_ERROR "Failed to find Lua ${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}")
            ENDIF()

            EXECUTE_PROCESS(
                COMMAND ${_LUA_INTERPRETER} "-v"
                OUTPUT_VARIABLE LUA_VERSION_CONTENT
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )

            IF (NOT ("${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}" STREQUAL "5.1") AND
                NOT LUA_VERSION_CONTENT MATCHES "^Lua .* PUC-Rio")
                MESSAGE(FATAL_ERROR "Failed to find a working Lua interpreter")
            ENDIF()

            EXECUTE_PROCESS(
                COMMAND ${_LUA_INTERPRETER} "-e" "print(_VERSION:sub(5))"
                OUTPUT_VARIABLE LUA_ABI_CONTENT
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )

            IF (NOT LUA_ABI_CONTENT STREQUAL "${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}")
                MESSAGE(FATAL_ERROR "Failed to find a working Lua interpreter")
            ENDIF()
        ENDIF()
    ELSE()
        _SETUP_LUA_UUID_FOR_LUAJIT()
    ENDIF()
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
    ELSE()
        SET(_INSTALL_KIND "LIBRARY")
    ENDIF()
ELSE()

    INCLUDE(GNUInstallDirs)

    IF (MSYS OR CYGWIN)
        SET(_INSTALL_KIND "RUNTIME")
        SET(_INSTALL_CMOD "${CMAKE_INSTALL_LIBDIR}/lua/${_LUA_ABI}")
    ELSEIF (WIN32)
        SET(_INSTALL_KIND "RUNTIME")
        IF ("${_LUA_ABI}" STREQUAL "5.1" OR "${_LUA_ABI}" STREQUAL "5.2")
            SET(_INSTALL_CMOD "${CMAKE_INSTALL_BINDIR}")
        ELSE()
            SET(_INSTALL_CMOD "${CMAKE_INSTALL_LIBDIR}/lua/${_LUA_ABI}")
        ENDIF()
    ELSE()
        SET(_INSTALL_KIND "LIBRARY")
        SET(_INSTALL_CMOD "${CMAKE_INSTALL_LIBDIR}/lua/${_LUA_ABI}")
    ENDIF()
ENDIF()

INSTALL(TARGETS lua-uuid
    "${_INSTALL_KIND}" DESTINATION "${_INSTALL_CMOD}"
)

IF (LUA_UUID_ENABLE_TESTS)
    FOREACH (_TEST_FILE ${_LUA_UUID_TEST_FILES})
        GET_FILENAME_COMPONENT(_BASENAME ${_TEST_FILE} NAME)
        ADD_TEST(NAME ${_BASENAME}
            COMMAND ${_LUA_INTERPRETER} ${_TEST_FILE}
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
IF (LUAJIT_FOUND)
MESSAGE(STATUS "   LuaJIT")
ELSE()
MESSAGE(STATUS "   Lua")
ENDIF()
MESSAGE(STATUS "     Version: ........... ${_LUA_ABI}")
MESSAGE(STATUS "     Include dir: ....... ${LUA_INCLUDE_DIR}")
IF (WIN32)
MESSAGE(STATUS "     Libraries: ......... ${LUA_LIBRARIES}")
ENDIF()
IF (LUA_UUID_ENABLE_TESTS)
MESSAGE(STATUS "     Interpreter: ....... ${_LUA_INTERPRETER}")
ENDIF()
IF (NOT (WIN32 OR APPLE))
MESSAGE(STATUS "   libuuid")
MESSAGE(STATUS "     Include dir: ....... ${LIBUUID_INCLUDE_DIR}")
MESSAGE(STATUS "     Libraries: ......... ${LIBUUID_LIBRARIES}")
MESSAGE(STATUS " ")
MESSAGE(STATUS " Install")
MESSAGE(STATUS "   Prefix: .............. ${CMAKE_INSTALL_PREFIX}")
MESSAGE(STATUS "   lua-uuid dir: ........ ${CMAKE_INSTALL_PREFIX}/${_INSTALL_CMOD}")
ENDIF()
MESSAGE(STATUS " ")
