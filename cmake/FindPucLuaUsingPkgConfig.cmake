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

FUNCTION(FIND_PUC_LUA_USING_PKG_CONFIG VERSION)
    IF (NOT DEFINED CMAKE_PARSE_ARGUMENTS)
        INCLUDE(CMakeParseArguments)
    ENDIF()
    CMAKE_PARSE_ARGUMENTS(
        PARSE_ARGV 1
        _FPLUSPC
        ""
        "ERROR_VARIABLE"
        ""
    )
    IF (_FPLUSPC_UNPARSED_ARGUMENTS)
        MESSAGE(FATAL_ERROR "FIND_PUC_LUA_USING_PKG_CONFIG(): ${_FPLUSPC_UNPARSED_ARGUMENTS}: unexpected arguments")
    ENDIF()
    IF (_FPLUSPC_ERROR_VARIABLE AND NOT ("${_FPLUSPC_ERROR_VARIABLE}" MATCHES "^[a-zA-Z_][a-zA-Z0-9_]*$"))
        MESSAGE(FATAL_ERROR "ERROR_VARIABLE is expected to be a valid variable name")
    ENDIF()
    SET(_VER_MAJ "-1")
    SET(_VER_MIN "-1")
    SET(_VER_REL "-1")
    IF (VERSION MATCHES "^([0-9]+)\\.([0-9]+)$")
        SET(_VER_MAJ "${CMAKE_MATCH_1}")
        SET(_VER_MIN "${CMAKE_MATCH_2}")
    ELSEIF (VERSION MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$")
        SET(_VER_MAJ "${CMAKE_MATCH_1}")
        SET(_VER_MIN "${CMAKE_MATCH_2}")
        SET(_VER_REL "${CMAKE_MATCH_3}")
    ELSE()
        IF (_FPLUSPC_ERROR_VARIABLE)
            SET(${_FPLUSPC_ERROR_VARIABLE} "Failed to find pkg-config" PARENT_SCOPE)
        ENDIF()
        SET(LUA_FOUND OFF PARENT_SCOPE)
        IF (_FPLUSPC_ERROR_VARIABLE)
            MARK_AS_ADVANCED(
                LUA_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUA_INTERPRETER
                LUA_INCLUDE_DIR
                LUA_LIBRARIES
                ${_FPLUSPC_ERROR_VARIABLE}
            )
        ELSE()
            MARK_AS_ADVANCED(
                LUA_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUA_INTERPRETER
                LUA_INCLUDE_DIR
                LUA_LIBRARIES
            )
        ENDIF()
        RETURN()
    ENDIF()
    IF (NOT DEFINED PKG_CHECK_MODULES)
        INCLUDE(FindPkgConfig)
    ENDIF()
    IF (NOT PKG_CONFIG_FOUND)
        IF (_FPLUSPC_ERROR_VARIABLE)
            SET(${_FPLUSPC_ERROR_VARIABLE} "Failed to find pkg-config" PARENT_SCOPE)
        ENDIF()
        SET(LUA_FOUND OFF PARENT_SCOPE)
        IF (_FPLUSPC_ERROR_VARIABLE)
            MARK_AS_ADVANCED(
                LUA_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUA_INTERPRETER
                LUA_INCLUDE_DIR
                LUA_LIBRARIES
                ${_FPLUSPC_ERROR_VARIABLE}
            )
        ELSE()
            MARK_AS_ADVANCED(
                LUA_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUA_INTERPRETER
                LUA_INCLUDE_DIR
                LUA_LIBRARIES
            )
        ENDIF()
        RETURN()
    ENDIF()
    SET(_LUA_INCLUDE_DIR)
    FOREACH (_LUA_PCNAME
        "lua${_VER_MAJ}.${_VER_MIN}"
        "lua${_VER_MAJ}${_VER_MIN}"
        "lua-${_VER_MAJ}.${_VER_MIN}"
        "lua-${_VER_MAJ}${_VER_MIN}"
        "lua")
        PKG_CHECK_MODULES(_LUA_PCMODULE ${_LUA_PCNAME} QUIET)

        IF (_LUA_PCMODULE_FOUND AND
            EXISTS "${_LUA_PCMODULE_INCLUDEDIR}/lua.h" AND
            EXISTS "${_LUA_PCMODULE_INCLUDEDIR}/luaconf.h" AND
            EXISTS "${_LUA_PCMODULE_INCLUDEDIR}/lualib.h" AND
            EXISTS "${_LUA_PCMODULE_INCLUDEDIR}/lauxlib.h" AND
            EXISTS "${_LUA_PCMODULE_INCLUDEDIR}/lua.hpp")

            FILE(READ "${_LUA_PCMODULE_INCLUDEDIR}/lua.h" _LUA_H)
            SET(_LUA_H_MAJOR "-1")
            SET(_LUA_H_MINOR "-1")
            SET(_LUA_H_RELEASE "-1")

            IF ("${_VER_MAJ}.${_VER_MIN}" STREQUAL "5.1")
                STRING(REGEX
                    MATCH "#define[ \t]+LUA_RELEASE[ \t]+\"Lua[ \t]+([0-9]+)\\.([0-9]+)\\.([0-9]+)\""
                    _LUA_VERSION_CHECK
                    "${_LUA_H}"
                )
                IF (_LUA_VERSION_CHECK)
                    SET(_LUA_H_MAJOR "${CMAKE_MATCH_1}")
                    SET(_LUA_H_MINOR "${CMAKE_MATCH_2}")
                    SET(_LUA_H_RELEASE "${CMAKE_MATCH_3}")
                ENDIF()
            ELSEIF("${_VER_MAJ}.${_VER_MIN}" VERSION_GREATER "5.1" AND
                   "${_VER_MAJ}.${_VER_MIN}" VERSION_LESS "5.5")
                STRING(REGEX
                    MATCH "#define[ \t]+LUA_VERSION_MAJOR[ \t]+\"([0-9]+)\""
                    _LUA_VERSION_CHECK
                    "${_LUA_H}"
                )
                IF (_LUA_VERSION_CHECK)
                    SET(_LUA_H_MAJOR "${CMAKE_MATCH_1}")
                    STRING(REGEX
                        MATCH "#define[ \t]+LUA_VERSION_MINOR[ \t]+\"([0-9]+)\""
                        _LUA_VERSION_CHECK
                        "${_LUA_H}"
                    )
                    IF (_LUA_VERSION_CHECK)
                        SET(_LUA_H_MINOR "${CMAKE_MATCH_1}")
                        STRING(REGEX
                            MATCH "#define[ \t]+LUA_VERSION_RELEASE[ \t]+\"([0-9]+)\""
                            _LUA_VERSION_CHECK
                            "${_LUA_H}"
                        )
                        IF (_LUA_VERSION_CHECK)
                            SET(_LUA_H_RELEASE "${CMAKE_MATCH_1}")
                        ENDIF()
                    ENDIF()
                ENDIF()
            ELSE()
                STRING(REGEX
                    MATCH "#define[ \t]+LUA_VERSION_MAJOR_N[ \t]+([0-9]+)"
                    _LUA_VERSION_CHECK
                    "${_LUA_H}"
                )
                IF (_LUA_VERSION_CHECK)
                    SET(_LUA_H_MAJOR "${CMAKE_MATCH_1}")
                    STRING(REGEX
                        MATCH "#define[ \t]+LUA_VERSION_MINOR_N[ \t]+([0-9]+)"
                        _LUA_VERSION_CHECK
                        "${_LUA_H}"
                    )
                    IF (_LUA_VERSION_CHECK)
                        SET(_LUA_H_MINOR "${CMAKE_MATCH_1}")
                        STRING(REGEX
                            MATCH "#define[ \t]+LUA_VERSION_RELEASE_N[ \t]+([0-9]+)"
                            _LUA_VERSION_CHECK
                            "${_LUA_H}"
                        )
                        IF (_LUA_VERSION_CHECK)
                            SET(_LUA_H_RELEASE "${CMAKE_MATCH_1}")
                        ENDIF()
                    ENDIF()
                ENDIF()
            ENDIF()

            IF ("${_VER_MAJ}.${_VER_MIN}" STREQUAL "${_LUA_H_MAJOR}.${_LUA_H_MINOR}")
                IF ("${_VER_REL}" STREQUAL "${_LUA_H_RELEASE}" OR "${_VER_REL}" STREQUAL "-1")
                    IF (_LUA_PCMODULE_VERSION MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$")
                        IF ("${CMAKE_MATCH_1}.${CMAKE_MATCH_2}" STREQUAL "${_VER_MAJ}.${_VER_MIN}" AND
                            ("${CMAKE_MATCH_3}" STREQUAL "${_VER_REL}" OR "${_VER_REL}" STREQUAL "-1"))
                            SET(_LUA_PREFIX "${_LUA_PCMODULE_PREFIX}")
                            SET(_LUA_INCLUDE_DIR "${_LUA_PCMODULE_INCLUDEDIR}")
                            SET(_LUA_LIBDIR "${_LUA_PCMODULE_LIBDIR}")
                            BREAK()
                        ENDIF()
                    ELSEIF (_LUA_PCMODULE_VERSION MATCHES "^([0-9]+)\\.([0-9]+)$")
                        IF ("${CMAKE_MATCH_1}.${CMAKE_MATCH_2}" STREQUAL "${_VER_MAJ}.${_VER_MIN}")
                            SET(_LUA_PREFIX "${_LUA_PCMODULE_PREFIX}")
                            SET(_LUA_INCLUDE_DIR "${_LUA_PCMODULE_INCLUDEDIR}")
                            SET(_LUA_LIBDIR "${_LUA_PCMODULE_LIBDIR}")
                            BREAK()
                        ENDIF()
                    ENDIF()
                ENDIF()
            ENDIF()
        ENDIF()
    ENDFOREACH()

    IF (NOT _LUA_INCLUDE_DIR)
        IF (_FPLUSPC_ERROR_VARIABLE)
            SET(${_FPLUSPC_ERROR_VARIABLE} "Failed to find Lua headers" PARENT_SCOPE)
        ENDIF()
        SET(LUA_FOUND OFF PARENT_SCOPE)
        IF (_FPLUSPC_ERROR_VARIABLE)
            MARK_AS_ADVANCED(
                LUA_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUA_INTERPRETER
                LUA_INCLUDE_DIR
                LUA_LIBRARIES
                ${_FPLUSPC_ERROR_VARIABLE}
            )
        ELSE()
            MARK_AS_ADVANCED(
                LUA_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUA_INTERPRETER
                LUA_INCLUDE_DIR
                LUA_LIBRARIES
            )
        ENDIF()
        RETURN()
    ENDIF()

    IF (WIN32)
        IF (MINGW)
            FIND_FILE(_LUA_LIBRARIES
                NAMES "lua${_VER_MAJ}${_VER_MIN}.dll"
                HINTS "${_LUA_PREFIX}"
                NO_DEFAULT_PATH
                PATH_SUFFIXES "bin"
                OPTIONAL
            )
        ELSE()
            FIND_LIBRARY(_LUA_LIBRARIES
                NAMES
                    "lua${_VER_MAJ}${_VER_MIN}"
                    "lua${_VER_MAJ}.${_VER_MIN}"
                    "lua-${_VER_MAJ}${_VER_MIN}"
                    "lua-${_VER_MAJ}.${_VER_MIN}"
                    "lua"
                HINTS "${_LUA_LIBDIR}"
                NO_DEFAULT_PATH
                OPTIONAL
            )
        ENDIF()

        IF (NOT _LUA_LIBRARIES)
            IF (_FPLUSPC_ERROR_VARIABLE)
                SET(${_FPLUSPC_ERROR_VARIABLE} "Failed to find import libraries for Lua" PARENT_SCOPE)
            ENDIF()
            SET(LUA_FOUND OFF PARENT_SCOPE)
            IF (_FPLUSPC_ERROR_VARIABLE)
                MARK_AS_ADVANCED(
                    LUA_FOUND
                    LUA_VERSION_MAJOR
                    LUA_VERSION_MINOR
                    LUA_INTERPRETER
                    LUA_INCLUDE_DIR
                    LUA_LIBRARIES
                    ${_FPLUSPC_ERROR_VARIABLE}
                )
            ELSE()
                MARK_AS_ADVANCED(
                    LUA_FOUND
                    LUA_VERSION_MAJOR
                    LUA_VERSION_MINOR
                    LUA_INTERPRETER
                    LUA_INCLUDE_DIR
                    LUA_LIBRARIES
                )
            ENDIF()
            RETURN()
        ENDIF()
    ELSE()
        FIND_LIBRARY(_LUA_LIBRARIES
            NAMES
                "lua${_VER_MAJ}${_VER_MIN}"
                "lua${_VER_MAJ}.${_VER_MIN}"
                "lua-${_VER_MAJ}${_VER_MIN}"
                "lua-${_VER_MAJ}.${_VER_MIN}"
                "lua"
            HINTS "${_LUA_LIBDIR}"
            NO_DEFAULT_PATH
            OPTIONAL
        )

        IF (NOT _LUA_LIBRARIES)
            IF (_FPLUSPC_ERROR_VARIABLE)
                SET(${_FPLUSPC_ERROR_VARIABLE} "Failed to find Lua libraries" PARENT_SCOPE)
            ENDIF()
            SET(LUA_FOUND OFF PARENT_SCOPE)
            IF (_FPLUSPC_ERROR_VARIABLE)
                MARK_AS_ADVANCED(
                    LUA_FOUND
                    LUA_VERSION_MAJOR
                    LUA_VERSION_MINOR
                    LUA_INTERPRETER
                    LUA_INCLUDE_DIR
                    LUA_LIBRARIES
                    ${_FPLUSPC_ERROR_VARIABLE}
                )
            ELSE()
                MARK_AS_ADVANCED(
                    LUA_FOUND
                    LUA_VERSION_MAJOR
                    LUA_VERSION_MINOR
                    LUA_INTERPRETER
                    LUA_INCLUDE_DIR
                    LUA_LIBRARIES
                )
            ENDIF()
            RETURN()
        ENDIF()
    ENDIF()

    FIND_PROGRAM(_LUA_INTERPRETER
        NAMES
            "lua${_VER_MAJ}${_VER_MIN}"
            "lua${_VER_MAJ}.${_VER_MIN}"
            "lua-${_VER_MAJ}${_VER_MIN}"
            "lua-${_VER_MAJ}.${_VER_MIN}"
            "lua"
        HINTS "${_LUA_PREFIX}"
        PATH_SUFFIXES "bin"
        NO_DEFAULT_PATH
        OPTIONAL
    )

    IF (NOT _LUA_INTERPRETER)
        IF (_FPLUSPC_ERROR_VARIABLE)
            SET(${_FPLUSPC_ERROR_VARIABLE} "Failed to find the Lua interpreter" PARENT_SCOPE)
        ENDIF()
        SET(LUA_FOUND OFF PARENT_SCOPE)
        IF (_FPLUSPC_ERROR_VARIABLE)
            MARK_AS_ADVANCED(
                LUA_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUA_INTERPRETER
                LUA_INCLUDE_DIR
                LUA_LIBRARIES
                ${_FPLUSPC_ERROR_VARIABLE}
            )
        ELSE()
            MARK_AS_ADVANCED(
                LUA_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUA_INTERPRETER
                LUA_INCLUDE_DIR
                LUA_LIBRARIES
            )
        ENDIF()
        RETURN()
    ENDIF()

    EXECUTE_PROCESS(
        COMMAND ${_LUA_INTERPRETER} "-v"
        OUTPUT_VARIABLE _LUA_VERSION_CONTENT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    IF (NOT ("${_VER_MAJ}.${_VER_MIN}" STREQUAL "5.1") AND
        NOT _LUA_VERSION_CONTENT MATCHES "^Lua .* PUC-Rio")
        IF (_FPLUSPC_ERROR_VARIABLE)
            SET(${_FPLUSPC_ERROR_VARIABLE} "Failed to find a working Lua interpreter" PARENT_SCOPE)
        ENDIF()
        SET(LUA_FOUND OFF PARENT_SCOPE)
        IF (_FPLUSPC_ERROR_VARIABLE)
            MARK_AS_ADVANCED(
                LUA_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUA_INTERPRETER
                LUA_INCLUDE_DIR
                LUA_LIBRARIES
                ${_FPLUSPC_ERROR_VARIABLE}
            )
        ELSE()
            MARK_AS_ADVANCED(
                LUA_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUA_INTERPRETER
                LUA_INCLUDE_DIR
                LUA_LIBRARIES
            )
        ENDIF()
        RETURN()
    ENDIF()

    EXECUTE_PROCESS(
        COMMAND ${_LUA_INTERPRETER} "-e" "print(_VERSION:sub(5))"
        OUTPUT_VARIABLE _LUA_ABI_CONTENT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    IF (NOT _LUA_ABI_CONTENT STREQUAL "${_VER_MAJ}.${_VER_MIN}")
        IF (_FPLUSPC_ERROR_VARIABLE)
            SET(${_FPLUSPC_ERROR_VARIABLE} "Failed to find a working Lua interpreter" PARENT_SCOPE)
        ENDIF()
        SET(LUA_FOUND OFF PARENT_SCOPE)
        IF (_FPLUSPC_ERROR_VARIABLE)
            MARK_AS_ADVANCED(
                LUA_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUA_INTERPRETER
                LUA_INCLUDE_DIR
                LUA_LIBRARIES
                ${_FPLUSPC_ERROR_VARIABLE}
            )
        ELSE()
            MARK_AS_ADVANCED(
                LUA_FOUND
                LUA_VERSION_MAJOR
                LUA_VERSION_MINOR
                LUA_INTERPRETER
                LUA_INCLUDE_DIR
                LUA_LIBRARIES
            )
        ENDIF()
        RETURN()
    ENDIF()

    SET(LUA_FOUND ON PARENT_SCOPE)
    SET(LUA_VERSION_MAJOR "${_VER_MAJ}" PARENT_SCOPE)
    SET(LUA_VERSION_MINOR "${_VER_MIN}" PARENT_SCOPE)
    SET(LUA_INTERPRETER ${_LUA_INTERPRETER} PARENT_SCOPE)
    SET(LUA_INCLUDE_DIR "${_LUA_INCLUDE_DIR}" PARENT_SCOPE)
    SET(LUA_LIBRARIES "${_LUA_LIBRARIES}" PARENT_SCOPE)
    IF (_FPLUSPC_ERROR_VARIABLE)
        UNSET(${_FPLUSPC_ERROR_VARIABLE} PARENT_SCOPE)
    ENDIF()

    IF (_FPLUSPC_ERROR_VARIABLE)
        MARK_AS_ADVANCED(
            LUA_FOUND
            LUA_VERSION_MAJOR
            LUA_VERSION_MINOR
            LUA_INTERPRETER
            LUA_INCLUDE_DIR
            LUA_LIBRARIES
            ${_FPLUSPC_ERROR_VARIABLE}
        )
    ELSE()
        MARK_AS_ADVANCED(
            LUA_FOUND
            LUA_VERSION_MAJOR
            LUA_VERSION_MINOR
            LUA_INTERPRETER
            LUA_INCLUDE_DIR
            LUA_LIBRARIES
        )
    ENDIF()
ENDFUNCTION()
