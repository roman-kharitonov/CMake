# - Check whether the C compiler supports a given flag.
# CHECK_C_COMPILER_FLAG(<flag> <var>)
#  <flag> - the compiler flag
#  <var>  - variable to store the result
# This internally calls the check_c_source_compiles macro and
# sets CMAKE_REQUIRED_DEFINITIONS to <flag>.
# See help for CheckCSourceCompiles for a listing of variables
# that can otherwise modify the build.
# The result only tells that the compiler does not give an error message when
# it encounters the flag. If the flag has any effect or even a specific one is
# beyond the scope of this module.

#=============================================================================
# Copyright 2006-2011 Kitware, Inc.
# Copyright 2006 Alexander Neundorf <neundorf@kde.org>
# Copyright 2011 Matthias Kretz <kretz@kde.org>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

include(CheckCSourceCompiles)

macro (CHECK_COMPILER_FLAG_COMMON_PATTERNS _VAR)
   set(${_VAR}
     FAIL_REGEX "unrecognized .*option"                     # GNU
     FAIL_REGEX "unknown .*option"                          # Clang
     FAIL_REGEX "ignoring unknown option"                   # MSVC
     FAIL_REGEX "warning D9002"                             # MSVC, any lang
     FAIL_REGEX "option.*not supported"                     # Intel
     FAIL_REGEX "invalid argument .*option"                 # Intel
     FAIL_REGEX "ignoring option .*argument required"       # Intel
     FAIL_REGEX "[Uu]nknown option"                         # HP
     FAIL_REGEX "[Ww]arning: [Oo]ption"                     # SunPro
     FAIL_REGEX "command option .* is not recognized"       # XL
     FAIL_REGEX "command option .* contains an incorrect subargument" # XL
     FAIL_REGEX "not supported in this configuration; ignored"       # AIX
     FAIL_REGEX "File with unknown suffix passed to linker" # PGI
     FAIL_REGEX "WARNING: unknown flag:"                    # Open64
     FAIL_REGEX "Incorrect command line option:"            # Borland
   )
endmacro ()

macro (CHECK_C_COMPILER_FLAG _FLAG _RESULT)
   set(SAFE_CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS}")
   set(CMAKE_REQUIRED_DEFINITIONS "${_FLAG}")

   # Normalize locale during test compilation.
   set(_CheckCCompilerFlag_LOCALE_VARS LC_ALL LC_MESSAGES LANG)
   foreach(v ${_CheckCCompilerFlag_LOCALE_VARS})
     set(_CheckCCompilerFlag_SAVED_${v} "$ENV{${v}}")
     set(ENV{${v}} C)
   endforeach()
   CHECK_COMPILER_FLAG_COMMON_PATTERNS(_CheckCCompilerFlag_COMMON_PATTERNS)
   CHECK_C_SOURCE_COMPILES("int main(void) { return 0; }" ${_RESULT}
     # Some compilers do not fail with a bad flag
     FAIL_REGEX "command line option .* is valid for .* but not for C" # GNU
     ${_CheckCCompilerFlag_COMMON_PATTERNS}
     )
   foreach(v ${_CheckCCompilerFlag_LOCALE_VARS})
     set(ENV{${v}} ${_CheckCCompilerFlag_SAVED_${v}})
     unset(_CheckCCompilerFlag_SAVED_${v})
   endforeach()
   unset(_CheckCCompilerFlag_LOCALE_VARS)
   unset(_CheckCCompilerFlag_COMMON_PATTERNS)

   set (CMAKE_REQUIRED_DEFINITIONS "${SAFE_CMAKE_REQUIRED_DEFINITIONS}")
endmacro ()
