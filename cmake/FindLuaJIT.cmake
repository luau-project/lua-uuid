#===================================================================================================#
# LICENSE (public domain)                                                                           #
#===================================================================================================#
#                                                                                                   #
# This is free and unencumbered software released into the public domain.                           #
#                                                                                                   #
# Anyone is free to copy, modify, publish, use, compile, sell, or                                   #
# distribute this software, either in source code form or as a compiled                             #
# binary, for any purpose, commercial or non-commercial, and by any                                 #
# means.                                                                                            #
#                                                                                                   #
# In jurisdictions that recognize copyright laws, the author or authors                             #
# of this software dedicate any and all copyright interest in the                                   #
# software to the public domain. We make this dedication for the benefit                            #
# of the public at large and to the detriment of our heirs and                                      #
# successors. We intend this dedication to be an overt act of                                       #
# relinquishment in perpetuity of all present and future rights to this                             #
# software under copyright law.                                                                     #
#                                                                                                   #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,                                   #
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                                #
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.                            #
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR                                 #
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,                             #
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR                             #
# OTHER DEALINGS IN THE SOFTWARE.                                                                   #
#                                                                                                   #
# For more information, please refer to <https://unlicense.org/>                                    #
#                                                                                                   #
#===================================================================================================#
# LICENSE (MIT) on countries that refuse public domain                                              #
#===================================================================================================#
#                                                                                                   #
# The MIT License (MIT)                                                                             #
#                                                                                                   #
# Copyright (c) 2026 FindLuaJIT.cmake contributors https://github.com/luau-project/FindLuaJIT.cmake #
#                                                                                                   #
# Permission is hereby granted, free of charge, to any person obtaining a copy                      #
# of this software and associated documentation files (the "Software"), to deal                     #
# in the Software without restriction, including without limitation the rights                      #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell                         #
# copies of the Software, and to permit persons to whom the Software is                             #
# furnished to do so, subject to the following conditions:                                          #
#                                                                                                   #
# The above copyright notice and this permission notice shall be included in all                    #
# copies or substantial portions of the Software.                                                   #
#                                                                                                   #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR                        #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,                          #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE                       #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER                            #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,                     #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE                     #
# SOFTWARE.                                                                                         #
#                                                                                                   #
#===================================================================================================#

#=======================================================================#
# Version: 0.0.1                                                        #
#=======================================================================#
# Usage:                                                                #
#=======================================================================#
#                                                                       #
# FIND_LUAJIT(ERROR_VARIABLE ERROR_MSG)                                 #
#                                                                       #
# IF (LUAJIT_FOUND)                                                     #
#     MESSAGE(STATUS "Include dir: .......... ${LUAJIT_INCLUDE_DIR}")   #
#     MESSAGE(STATUS "Libraries: ............ ${LUAJIT_LIBRARIES}")     #
#     MESSAGE(STATUS "LuaJIT interpreter: ... ${LUAJIT_INTERPRETER}")   #
#     MESSAGE(STATUS "Lua version major: .... ${LUA_VERSION_MAJOR}")    #
#     MESSAGE(STATUS "Lua version minor: .... ${LUA_VERSION_MINOR}")    #
# ELSE()                                                                #
#     MESSAGE(FATAL_ERROR "${ERROR_MSG}")                               #
# ENDIF()                                                               #
#                                                                       #
#=======================================================================#

FUNCTION(FIND_LUAJIT)
    IF (NOT DEFINED CMAKE_PARSE_ARGUMENTS)
        INCLUDE(CMakeParseArguments)
    ENDIF()
    CMAKE_PARSE_ARGUMENTS(
        PARSE_ARGV 0
        _FLJ
        ""
        "ERROR_VARIABLE"
        ""
    )
    IF (_FLJ_UNPARSED_ARGUMENTS)
        MESSAGE(FATAL_ERROR "FIND_LUAJIT(): ${_FLJ_UNPARSED_ARGUMENTS}: unexpected arguments")
    ENDIF()
    IF (_FLJ_ERROR_VARIABLE AND NOT ("${_FLJ_ERROR_VARIABLE}" MATCHES "^[a-zA-Z_]?[a-zA-Z0-9_]+$"))
        MESSAGE(FATAL_ERROR "ERROR_VARIABLE is expected to be a valid variable name")
    ENDIF()
    FOREACH(LUAJIT_SUFFIX "-2.1" "" "-2.0")
        FIND_PATH(_LUAJIT_INCLUDE_DIR
            NAMES "luajit.h"
            HINTS
                ENV LUAJIT_DIR
                ENV LUA_DIR
            PATH_SUFFIXES
                "include/luajit${LUAJIT_SUFFIX}"
                "luajit${LUAJIT_SUFFIX}"
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
        IF (_FLJ_ERROR_VARIABLE)
            SET(${_FLJ_ERROR_VARIABLE} "Failed to find LuaJIT headers" PARENT_SCOPE)
        ENDIF()
        SET(LUAJIT_FOUND OFF PARENT_SCOPE)
        IF (_FLJ_ERROR_VARIABLE)
            MARK_AS_ADVANCED(
                LUAJIT_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUAJIT_INTERPRETER
                LUAJIT_INCLUDE_DIR
                LUAJIT_LIBRARIES
                ${_FLJ_ERROR_VARIABLE}
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
                HINTS
                    ENV LUAJIT_DIR
                    ENV LUA_DIR
                PATH_SUFFIXES "bin"
                OPTIONAL
            )
        ELSE()
            FIND_LIBRARY(_LUAJIT_LIBRARIES
                NAMES "lua51"
                HINTS
                    ENV LUAJIT_DIR
                    ENV LUA_DIR
                PATH_SUFFIXES "lib"
                OPTIONAL
            )
        ENDIF()

        IF (NOT _LUAJIT_LIBRARIES)
            IF (_FLJ_ERROR_VARIABLE)
                SET(${_FLJ_ERROR_VARIABLE} "Failed to find import libraries for LuaJIT" PARENT_SCOPE)
            ENDIF()
            SET(LUAJIT_FOUND OFF PARENT_SCOPE)
            IF (_FLJ_ERROR_VARIABLE)
                MARK_AS_ADVANCED(
                    LUAJIT_FOUND
                    LUA_VERSION_MAJOR
                    LUA_VERSION_MINOR
                    LUAJIT_INTERPRETER
                    LUAJIT_INCLUDE_DIR
                    LUAJIT_LIBRARIES
                    ${_FLJ_ERROR_VARIABLE}
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
            HINTS
                ENV LUAJIT_DIR
                ENV LUA_DIR
            PATH_SUFFIXES "lib"
            OPTIONAL
        )

        IF (NOT _LUAJIT_LIBRARIES)
            IF (_FLJ_ERROR_VARIABLE)
                SET(${_FLJ_ERROR_VARIABLE} "Failed to find LuaJIT library" PARENT_SCOPE)
            ENDIF()
            SET(LUAJIT_FOUND OFF PARENT_SCOPE)
            IF (_FLJ_ERROR_VARIABLE)
                MARK_AS_ADVANCED(
                    LUAJIT_FOUND
                    LUA_VERSION_MAJOR
                    LUA_VERSION_MINOR
                    LUAJIT_INTERPRETER
                    LUAJIT_INCLUDE_DIR
                    LUAJIT_LIBRARIES
                    ${_FLJ_ERROR_VARIABLE}
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
        HINTS
            ENV LUAJIT_DIR
            ENV LUA_DIR
        PATH_SUFFIXES "bin"
        OPTIONAL
    )

    IF (NOT _LUAJIT_INTERPRETER)
        IF (_FLJ_ERROR_VARIABLE)
            SET(${_FLJ_ERROR_VARIABLE} "Failed to find LuaJIT" PARENT_SCOPE)
        ENDIF()
        SET(LUAJIT_FOUND OFF PARENT_SCOPE)
        IF (_FLJ_ERROR_VARIABLE)
            MARK_AS_ADVANCED(
                LUAJIT_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUAJIT_INTERPRETER
                LUAJIT_INCLUDE_DIR
                LUAJIT_LIBRARIES
                ${_FLJ_ERROR_VARIABLE}
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
        IF (_FLJ_ERROR_VARIABLE)
            SET(${_FLJ_ERROR_VARIABLE} "Failed to find a working LuaJIT interpreter" PARENT_SCOPE)
        ENDIF()
        SET(LUAJIT_FOUND OFF PARENT_SCOPE)
        IF (_FLJ_ERROR_VARIABLE)
            MARK_AS_ADVANCED(
                LUAJIT_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUAJIT_INTERPRETER
                LUAJIT_INCLUDE_DIR
                LUAJIT_LIBRARIES
                ${_FLJ_ERROR_VARIABLE}
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
        IF (_FLJ_ERROR_VARIABLE)
            SET(${_FLJ_ERROR_VARIABLE} "Failed to find a working LuaJIT interpreter" PARENT_SCOPE)
        ENDIF()
        SET(LUAJIT_FOUND OFF PARENT_SCOPE)
        IF (_FLJ_ERROR_VARIABLE)
            MARK_AS_ADVANCED(
                LUAJIT_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUAJIT_INTERPRETER
                LUAJIT_INCLUDE_DIR
                LUAJIT_LIBRARIES
                ${_FLJ_ERROR_VARIABLE}
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
    IF (_FLJ_ERROR_VARIABLE)
        UNSET(${_FLJ_ERROR_VARIABLE} PARENT_SCOPE)
    ENDIF()

    IF (_FLJ_ERROR_VARIABLE)
        MARK_AS_ADVANCED(
            LUAJIT_FOUND
            LUA_VERSION_MAJOR
            LUA_VERSION_MINOR
            LUAJIT_INTERPRETER
            LUAJIT_INCLUDE_DIR
            LUAJIT_LIBRARIES
            ${_FLJ_ERROR_VARIABLE}
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
