#
# Example: cmake -G "NMake Makefiles"
#
# Note that perl had real problems with symlink on MSWin32 between 5.34 and
# 5.36 - this is fixed since 5.37.4, therefore building a 5.37.4 version at
# least is recommended.
#
# We use distproprefs that will require patch.exe and git.
# The easiest way to get it is to install "Git For Windows" (https://gitforwindows.org/) and do:
#
# SET PATH=%PATH%;C:\Program Files\Git\bin;C:\Program Files\Git\usr\bin
#
# before running cmake.
#
project(perlbuildwindows LANGUAGES C CXX)
#
# We require version 3.14 to have:
# - SOURCE_SUBDIR working with BUILD_IN_SOURCE
# - CMP0077
#
cmake_minimum_required(VERSION 3.14)
#
# Look for patch command - this is required
#
find_package(Patch)
if (NOT Patch_FOUND)
  message(FATAL_ERROR "Patch not found")
endif()
#
# We want to make sure that our local .cpan setup find patch executable
#
get_filename_component(PATCH_PROGRAM_ABSOLUTE_PATH ${Patch_EXECUTABLE} ABSOLUTE)
cmake_path(CONVERT "${PATCH_PROGRAM_ABSOLUTE_PATH}" TO_NATIVE_PATH_LIST PATCH_PROGRAM_ABSOLUTE_PATH_DOS)

#
# Get list of logical drives
#
execute_process(COMMAND wmic logicaldisk get name
                TIMEOUT 10
				RESULT_VARIABLE  wmic_logicaldisk_get_name_result
				OUTPUT_VARIABLE  wmic_logicaldisk_get_name_output
				ERROR_VARIABLE   wmic_logicaldisk_get_name_error
				)
string(TOUPPER ${wmic_logicaldisk_get_name_output} wmic_logicaldisk_get_name_output)
string(REGEX REPLACE "[\t\r\n]+" " " wmic_logicaldisk_get_name_output ${wmic_logicaldisk_get_name_output})
string(REGEX MATCHALL "[a-zA-Z]:" drives ${wmic_logicaldisk_get_name_output})

list(LENGTH drives drives_length)
if (drives_length GREATER 0)
  if ("C:" IN_LIST drives)
    set (PERL_INST_DRV_DEFAULT C:)
  else ()
    set (PERL_INST_DRV_DEFAULT OFF)
  endif ()
else ()
  set (PERL_INST_DRV_DEFAULT OFF)
endif ()

#
# Get list of perl versions
#
file(DOWNLOAD https://raw.githubusercontent.com/skaji/perl-releases/main/perl-releases.v1.csv
     TIMEOUT  30
	 "${CMAKE_CURRENT_BINARY_DIR}/perl-releases.v1.csv")
# file(STRINGS "${CMAKE_CURRENT_BINARY_DIR}/perl-releases.v1.csv" perl_relases REGEX ",stable,")
file(STRINGS "${CMAKE_CURRENT_BINARY_DIR}/perl-releases.v1.csv" perl_relases)
set(PERL_VERSIONS)
foreach(perl_release ${perl_relases})
  string(REPLACE "," ";" perl_release ${perl_release})
  list(GET perl_release 2 perl_release_version)
  list(APPEND PERL_VERSIONS ${perl_release_version})
endforeach()

list(LENGTH PERL_VERSIONS PERL_VERSIONS_length)
if (PERL_VERSIONS_length GREATER 0)
  list(GET PERL_VERSIONS 0 PERL_VERSION_DEFAULT)
else ()
  set (PERL_VERSION_DEFAULT OFF)
endif ()

set (OPENSSL_VERSION_DEFAULT               3.0.5)
set (NASM_VERSION_DEFAULT                  2.15.05)
set (PERL_NET_SSLEAY_VERSION_DEFAULT       1.93_01)
set (PERL_WIN32_GUI_VERSION_DEFAULT        1.14)
set (ZLIB_VERSION_DEFAULT                  1.2.13)
set (EXPAT_VERSION_DEFAULT                 2.5.0)
set (FRIBIDI_VERSION_DEFAULT               1.0.12)
set (GIFLIB_VERSION_DEFAULT                5.2.1)
set (FREEIMAGE_VERSION_DEFAULT             3.18.0)
set (THAI_VERSION_DEFAULT                  0.1.29)
set (DATRIE_VERSION_DEFAULT                0.2.13)
set (LIBICONV_VERSION_DEFAULT              1.17)
set (LIBHEIF_VERSION_DEFAULT               1.13.0)
set (LIBDE265_VERSION_DEFAULT              1.0.9)
set (SDL2_VERSION_DEFAULT                  2.26.0)
set (SDL12_COMPAT_VERSION_DEFAULT          1.2.60)
set (X265_VERSION_DEFAULT                  3.4)
set (AOM_VERSION_DEFAULT                   3.5.0)
set (LIBJPEG_TURBO_VERSION_DEFAULT         2.1.4)
set (LIBPNG_VERSION_DEFAULT                1.6.39)
set (TIFF_VERSION_DEFAULT                  4.4.0)
set (LIBDEFLATE_VERSION_DEFAULT            1.14)
set (JBIGKIT_VERSION_DEFAULT               2.1)

set (PERL_INST_DRV                 ${PERL_INST_DRV_DEFAULT}                 CACHE STRING "perl installation drive")
set (PERL_VERSION                  ${PERL_VERSION_DEFAULT}                  CACHE STRING "perl version")
set (OPENSSL_VERSION               ${OPENSSL_VERSION_DEFAULT}               CACHE STRING "openssl version")
set (NASM_VERSION                  ${NASM_VERSION_DEFAULT}                  CACHE STRING "nasm version")
set (PERL_NET_SSLEAY_VERSION       ${PERL_NET_SSLEAY_VERSION_DEFAULT}       CACHE STRING "specific Net::SSLeay version")
set (PERL_WIN32_GUI_VERSION        ${PERL_WIN32_GUI_VERSION_DEFAULT}        CACHE STRING "specific Win32::GUI version")
set (ZLIB_VERSION                  ${ZLIB_VERSION_DEFAULT}                  CACHE STRING "zlib version")
set (EXPAT_VERSION                 ${EXPAT_VERSION_DEFAULT}                 CACHE STRING "expat version")
set (FRIBIDI_VERSION               ${FRIBIDI_VERSION_DEFAULT}               CACHE STRING "fribidi version")
set (GIFLIB_VERSION                ${GIFLIB_VERSION_DEFAULT}                CACHE STRING "giflib version")
set (FREEIMAGE_VERSION             ${FREEIMAGE_VERSION_DEFAULT}             CACHE STRING "freeimage version")
set (THAI_VERSION                  ${THAI_VERSION_DEFAULT}                  CACHE STRING "thai version")
set (DATRIE_VERSION                ${DATRIE_VERSION_DEFAULT}                CACHE STRING "datrie version")
set (LIBICONV_VERSION              ${LIBICONV_VERSION_DEFAULT}              CACHE STRING "libiconv version")
set (LIBHEIF_VERSION               ${LIBHEIF_VERSION_DEFAULT}               CACHE STRING "libheif version")
set (LIBDE265_VERSION              ${LIBDE265_VERSION_DEFAULT}              CACHE STRING "libde265 version")
set (SDL2_VERSION                  ${SDL2_VERSION_DEFAULT}                  CACHE STRING "SDL2 version")
set (SDL12_COMPAT_VERSION          ${SDL12_COMPAT_VERSION_DEFAULT}          CACHE STRING "sdl1.2-compat version")
set (X265_VERSION                  ${X265_VERSION_DEFAULT}                  CACHE STRING "x265 version")
set (AOM_VERSION                   ${AOM_VERSION_DEFAULT}                   CACHE STRING "aom version")
set (LIBJPEG_TURBO_VERSION         ${LIBJPEG_TURBO_VERSION_DEFAULT}         CACHE STRING "libjpeg-turbo version")
set (LIBPNG_VERSION                ${LIBPNG_VERSION_DEFAULT}                CACHE STRING "libpng version")
set (TIFF_VERSION                  ${TIFF_VERSION_DEFAULT}                  CACHE STRING "tiff version")
set (LIBDEFLATE_VERSION            ${LIBDEFLATE_VERSION_DEFAULT}            CACHE STRING "libdeflate version")
set (JBIGKIT_VERSION               ${JBIGKIT_VERSION_DEFAULT}               CACHE STRING "jbigkit version")

set_property (CACHE PERL_INST_DRV                 PROPERTY STRINGS ${drives} )
set_property (CACHE PERL_VERSION                  PROPERTY STRINGS ${PERL_VERSIONS})
set_property (CACHE OPENSSL_VERSION               PROPERTY STRINGS ${OPENSSL_VERSION_DEFAULT})
set_property (CACHE NASM_VERSION                  PROPERTY STRINGS ${NASM_VERSION_DEFAULT})
set_property (CACHE PERL_NET_SSLEAY_VERSION       PROPERTY STRINGS ${PERL_NET_SSLEAY_VERSION_DEFAULT})
set_property (CACHE PERL_WIN32_GUI_VERSION        PROPERTY STRINGS ${PERL_WIN32_GUI_VERSION_DEFAULT})
set_property (CACHE ZLIB_VERSION                  PROPERTY STRINGS ${ZLIB_VERSION_DEFAULT})
set_property (CACHE EXPAT_VERSION                 PROPERTY STRINGS ${EXPAT_VERSION_DEFAULT})
set_property (CACHE FRIBIDI_VERSION               PROPERTY STRINGS ${FRIBIDI_VERSION_DEFAULT})
set_property (CACHE GIFLIB_VERSION                PROPERTY STRINGS ${GIFLIB_VERSION_DEFAULT})
set_property (CACHE FREEIMAGE_VERSION             PROPERTY STRINGS ${FREEIMAGE_VERSION_DEFAULT})
set_property (CACHE THAI_VERSION                  PROPERTY STRINGS ${THAI_VERSION_DEFAULT})
set_property (CACHE DATRIE_VERSION                PROPERTY STRINGS ${DATRIE_VERSION_DEFAULT})
set_property (CACHE LIBICONV_VERSION              PROPERTY STRINGS ${LIBICONV_VERSION_DEFAULT})
set_property (CACHE LIBHEIF_VERSION               PROPERTY STRINGS ${LIBHEIF_VERSION_DEFAULT})
set_property (CACHE LIBDE265_VERSION              PROPERTY STRINGS ${LIBDE265_VERSION_DEFAULT})
set_property (CACHE SDL2_VERSION                  PROPERTY STRINGS ${SDL2_VERSION_DEFAULT})
set_property (CACHE SDL12_COMPAT_VERSION          PROPERTY STRINGS ${SDL12_COMPAT_VERSION_DEFAULT})
set_property (CACHE X265_VERSION                  PROPERTY STRINGS ${X265_VERSION_DEFAULT})
set_property (CACHE LIBJPEG_TURBO_VERSION         PROPERTY STRINGS ${LIBJPEG_TURBO_VERSION_DEFAULT})
set_property (CACHE LIBPNG_VERSION                PROPERTY STRINGS ${LIBPNG_VERSION_DEFAULT})
set_property (CACHE TIFF_VERSION                  PROPERTY STRINGS ${TIFF_VERSION_DEFAULT})
set_property (CACHE LIBDEFLATE_VERSION            PROPERTY STRINGS ${LIBDEFLATE_VERSION_DEFAULT})
set_property (CACHE JBIGKIT_VERSION               PROPERTY STRINGS ${JBIGKIT_VERSION_DEFAULT})

message (STATUS "===================================")
message (STATUS "Version of Perl                   : ${PERL_VERSION}")
message (STATUS "===================================")
message (STATUS "Version of nasm                   : ${NASM_VERSION}")
message (STATUS "Version of Net::SSLeay            : ${PERL_NET_SSLEAY_VERSION}")
message (STATUS "Version of openssl                : ${OPENSSL_VERSION}")
message (STATUS "Version of Win32::GUI             : ${PERL_WIN32_GUI_VERSION}")
message (STATUS "Version of zlib                   : ${ZLIB_VERSION}")
message (STATUS "Version of expat                  : ${EXPAT_VERSION}")
message (STATUS "Version of fribidi                : ${FRIBIDI_VERSION}")
message (STATUS "Version of giflib                 : ${GIFLIB_VERSION}")
message (STATUS "Version of freeimage              : ${FREEIMAGE_VERSION}")
message (STATUS "Version of thai                   : ${THAI_VERSION}")
message (STATUS "Version of datrie                 : ${DATRIE_VERSION}")
message (STATUS "Version of libiconv               : ${LIBICONV_VERSION}")
message (STATUS "Version of libheif                : ${LIBHEIF_VERSION}")
message (STATUS "Version of libde265               : ${LIBDE265_VERSION}")
message (STATUS "Version of SDL2                   : ${SDL2_VERSION}")
message (STATUS "Version of sdl2-compat            : ${SDL12_COMPAT_VERSION}")
message (STATUS "Version of x265                   : ${X265_VERSION}")
message (STATUS "Version of aom                    : ${AOM_VERSION}")
message (STATUS "Version of libjpeg-turbo          : ${LIBJPEG_TURBO_VERSION}")
message (STATUS "Version of libpng                 : ${LIBPNG_VERSION}")
message (STATUS "Version of tiff                   : ${TIFF_VERSION}")
message (STATUS "Version of libdeflate             : ${LIBDEFLATE_VERSION}")
message (STATUS "Version of jbigkit                : ${JBIGKIT_VERSION}")
message (STATUS "===================================")
#
# Set some nervous policies
#
foreach (_policy CMP0135)
  if (POLICY ${_policy})
    cmake_policy(SET ${_policy} NEW)
  endif ()
endforeach ()

#
# Check compiler is Microsoft Visual C++ using nmake
#
if (NOT MSVC)
  message(FATAL_ERROR "Compiler must be MSVC")
endif()
if (NOT CMAKE_GENERATOR STREQUAL "NMake Makefiles")
  message(FATAL_ERROR "Generator must be \"NMake Makefiles\", i.e. -G \"NMake Makefiles\"")
endif ()

#
# Check PERL_CCTYPE and PERL_WIN64 that we override in perl's win32/Makefile
#
if (MSVC12)
  set(PERL_CCTYPE "MSVC120")
elseif (MSVC_VERSION LESS 1910)
  set(PERL_CCTYPE "MSVC140")
elseif (MSVC_VERSION LESS 1920)
  set(PERL_CCTYPE "MSVC141")
elseif (MSVC_VERSION LESS 1930)
  set(PERL_CCTYPE "MSVC142")
elseif (MSVC_VERSION LESS 1940)
  set(PERL_CCTYPE "MSVC143")
elseif (MSVC_VERSION LESS 1800)
  #
  # Perl's Makefile says that only MSVC 120 and higher is supported
  #
  message(FATAL_ERROR "MSVC_VERSION ${MSVC_VERSION} is too old")
endif()
message (STATUS "PERL_CCTYPE              : ${PERL_CCTYPE}")

if (CMAKE_SIZEOF_VOID_P EQUAL 8)
  set (PERL_INSTSUBDIR "cl-perl-${PERL_VERSION}-64bit")
  set (PERL_WIN64 "#WIN64")
  set (OPENSSL_VC "VC-WIN64A")
  set (OPENSSL_LDFLAGS "/debug")
else ()
  set (PERL_INSTSUBDIR "cl-perl-${PERL_VERSION}-32bit")
  if (CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "AMD64")
    set (PERL_WIN64 "WIN64")
	#
	# perl Configure VC-WIN32 on a x64-to-x86 environment fails at linking
	#
    set (OPENSSL_LDFLAGS "/debug /machine:X86")
  else()
    set (PERL_WIN64 "#WIN64")
    set (OPENSSL_LDFLAGS "/debug")
  endif ()
  set (OPENSSL_VC "VC-WIN32")
endif ()
message (STATUS "WIN64 in perl's Makefile : ${PERL_WIN64}")

include(ExternalProject)

#
# Get full paths of our tools a-la-Windows when we need to call them in dos modes
#
set (PERLPATCH_BAT "${PROJECT_SOURCE_DIR}/perlpatch.bat")
cmake_path(CONVERT "${PERLPATCH_BAT}" TO_NATIVE_PATH_LIST PERLPATCH_BAT_DOS)

set (REPLACE_VBS_DOS "${PROJECT_SOURCE_DIR}/replace.vbs")
cmake_path(CONVERT "${REPLACE_VBS_DOS}" TO_NATIVE_PATH_LIST REPLACE_VBS_DOS)

set (CMAKE_COMMAND_DOS "${CMAKE_COMMAND}")
cmake_path(CONVERT "${CMAKE_COMMAND}" TO_NATIVE_PATH_LIST CMAKE_COMMAND_DOS)

set (CMAKE_CURRENT_BINARY_DIR_DOS "${CMAKE_CURRENT_BINARY_DIR}")
cmake_path(CONVERT "${CMAKE_CURRENT_BINARY_DIR}" TO_NATIVE_PATH_LIST CMAKE_CURRENT_BINARY_DIR_DOS)

set (PERL_INST_DIR "${PERL_INST_DRV}/${PERL_INSTSUBDIR}")
cmake_path(CONVERT "${PERL_INST_DIR}" TO_NATIVE_PATH_LIST PERL_INST_DIR_DOS)

set (PERL_BIN_INST_DIR "${PERL_INST_DRV}/${PERL_INSTSUBDIR}/bin")
cmake_path(CONVERT "${PERL_BIN_INST_DIR}" TO_NATIVE_PATH_LIST PERL_BIN_INST_DIR_DOS)

set (PERL_C_INST_DIR "${PERL_INST_DIR}/c")
cmake_path(CONVERT "${PERL_C_INST_DIR}" TO_NATIVE_PATH_LIST PERL_C_INST_DIR_DOS)

set (PERL_C_INCLUDE_INST_DIR "${PERL_INST_DIR}/c/include")
cmake_path(CONVERT "${PERL_C_INCLUDE_INST_DIR}" TO_NATIVE_PATH_LIST PERL_C_INCLUDE_INST_DIR_DOS)

set (PERL_C_LIB_INST_DIR "${PERL_INST_DIR}/c/lib")
cmake_path(CONVERT "${PERL_C_LIB_INST_DIR}" TO_NATIVE_PATH_LIST PERL_C_LIB_INST_DIR_DOS)

set (PERL_C_BIN_INST_DIR "${PERL_INST_DIR}/c/bin")
cmake_path(CONVERT "${PERL_C_BIN_INST_DIR}" TO_NATIVE_PATH_LIST PERL_C_BIN_INST_DIR_DOS)

set (CPAN_PATCHES_DIR "${CMAKE_CURRENT_BINARY_DIR}/.cpan/patches")
cmake_path(CONVERT "${CPAN_PATCHES_DIR}" TO_NATIVE_PATH_LIST CPAN_PATCHES_DIR_DOS)

set (PERL_C_PKGCONFIG_INST_DIR "${PERL_INST_DIR}/c/pkgconfig")
cmake_path(CONVERT "${PERL_C_PKGCONFIG_INST_DIR}" TO_NATIVE_PATH_LIST PERL_C_PKGCONFIG_INST_DIR)

# =======================================================
# Generic bat file to invoke anything related to our perl
# =======================================================
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat
"@ECHO OFF

REM
REM For Net::SSLeay...
REM
SET OPENSSL_PREFIX=${PERL_C_INST_DIR_DOS}

REM
REM For Win32::GUI...
REM
SET WIN32_GUI_USE_FREEIMAGE_DLL=1
SET WIN32_GUI_FREEIMAGE_EXTLIB=${PERL_C_LIB_INST_DIR_DOS}\\freeimage.lib
SET WIN32_GUI_FREEIMAGE_INCDIR=${PERL_C_INCLUDE_INST_DIR_DOS}

REM
REM For use XML::Parser
REM
SET EXPATLIBPATH=${PERL_C_LIB_INST_DIR_DOS}
SET EXPATINCPATH=${PERL_C_INCLUDE_INST_DIR_DOS}
SET EXPATLIBPREFIX=lib

REM
REM For PkgConfig
REM
SET PERL_PKG_CONFIG_SCRIPTS=ppkg-config,pkg-config
SET PKG_CONFIG_PATH=${PERL_C_PKGCONFIG_INST_DIR}
REM
REM Painful but libjpeg-turbo, libheif, etc... decide to install its pc files under lib
REM
SET PKG_CONFIG_PATH=%PKG_CONFIG_PATH%;${PERL_C_LIB_INST_DIR_DOS}\\pkgconfig

REM
REM For runtime of the above packages, we absolutely want perl to be before
REM
SET PATH=${PERL_BIN_INST_DIR_DOS};${PERL_C_BIN_INST_DIR_DOS};%PATH%

REM
REM For CPAN
REM
SET HOME=${CMAKE_CURRENT_BINARY_DIR_DOS}

REM
REM We want to have our OWN distro prefs. This mean our OWN .cpan
REM
REM If you look closely to CPAN::HandleConfig.pm you will see that:
REM - If File::HomeDir is usable it gives precedence do
REM   File::HomeDir->my_data that will give  %LOCALAPPDATA%\\.cpan
REM   File::HomeDir->my_home that will give  %HOME%\\.cpan or %USERPROFILE%\\.cpan or %HOMEDRIVE%%HOMEPATH%\\.cpan
REM - In any case:
REM   %HOME%\\.cpan if it exist
REM   %HOMEDRIVE%%HOMEPATH%\\.cpan if it exist
REM   %USERPROFILE\\.cpan if it exist
REM This mean that removing %APPDATA%\\.cpan and setting HOME to current directory will give a predictable .cpan
REM This can sound dangerous, but this is ok because the /first/ time CPAN is instanciated, by definition File::HomeDir
REM is not present, so cpan will default to one of the three cases that are always applied, and %APPDATA% is not one of them
REM
IF EXIST %LOCALAPPDATA%\\.cpan RMDIR /Q /S %LOCALAPPDATA%\\.cpan
REM
REM The very first time we initialize .cpan/CPAN/MyConfig and cpan will overwrite it
REM
IF NOT EXIST \"%HOME%\\.cpan\" (
	ECHO ======================================================
	ECHO Local CPAN Initialization for custom patches and prefs
	ECHO ======================================================
	MKDIR \"%HOME%\\.cpan\"
	IF NOT EXIST \"%HOME%\\.cpan\\CPAN\" MKDIR \"%HOME%\\.cpan\\CPAN\"
	IF NOT EXIST \"%HOME%\\.cpan\\prefs\" (
	  MKDIR \"%HOME%\\.cpan\\prefs\" 
	  COPY /Y \"${PROJECT_SOURCE_DIR}\\prefs\\*\" \"%HOME%\\.cpan\\prefs\"
	)
	IF NOT EXIST \"%HOME%\\.cpan\\patches\" (
	  MKDIR \"%HOME%\\.cpan\\patches\"
	  COPY /Y \"${PROJECT_SOURCE_DIR}\\patches\\*\" \"%HOME%\\.cpan\\patches\"
	)
	IF NOT EXIST \"%HOME%\\.cpan\\CPAN\\MyConfig.pm\" (
	  ECHO $CPAN::Config{cpan_home} = '${CMAKE_CURRENT_BINARY_DIR}'; > \"%HOME%\\.cpan\\CPAN\\MyConfig.pm\"
	  ECHO 1; >> \"%HOME%\\.cpan\\CPAN\\MyConfig.pm\"

	  REM
	  REM First instance that will ask questions
	  REM
	  ECHO | cpan

	  REM
	  REM CPAN settings
	  REM
	  REM - Make sure we use \"patch\" as per CMake findings
	  REM - patches_dir can be set only via o conf
	  REM
	  DEL .\\tmpFile
	  ECHO o conf patch '${PATCH_PROGRAM_ABSOLUTE_PATH_DOS}' > .\\tmpFile
	  ECHO o conf patches_dir '${CPAN_PATCHES_DIR_DOS}' >> .\\tmpFile
	  ECHO o conf commit >> .\\tmpFile
	  TYPE .\\tmpFile | cpan
	  DEL .\\tmpFile
	)
	REM
	REM We want to make sure that YAML is installed
	REM We add CPAN::DistnameInfo because CPAN is boring suggesting constantly this module
	REM
	ECHO | cpan YAML CPAN::DistnameInfo
)

REM
REM Execute the command
REM
ECHO | cmd /C %*
")

# ===========================================================
# Install system files
# ===========================================================
include(InstallRequiredSystemLibraries)

# ===========================================================
# External project perl-core
# ===========================================================
ExternalProject_Add(perl-core
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/perl-core-${PERL_VERSION}.tar.gz
					SOURCE_SUBDIR          win32
					PATCH_COMMAND          ${CMAKE_COMMAND} -E env ${PERLPATCH_BAT_DOS} ${REPLACE_VBS_DOS} ${PERL_CCTYPE} ${PERL_WIN64} ${PERL_INSTSUBDIR} ${PERL_INST_DRV}
					COMMAND                ${Patch_EXECUTABLE} inline.h         ${PROJECT_SOURCE_DIR}/patches/perl-rt12986-inline.h.patch
					COMMAND                ${Patch_EXECUTABLE} win32/win32.c    ${PROJECT_SOURCE_DIR}/patches/perl-rt12986-win32-win32.c.patch
					COMMAND                ${Patch_EXECUTABLE} win32/win32.h    ${PROJECT_SOURCE_DIR}/patches/perl-rt12986-win32-win32.h.patch
					COMMAND                ${Patch_EXECUTABLE} win32/win32sck.c ${PROJECT_SOURCE_DIR}/patches/perl-rt12986-win32-win32sck.c.patch
					CONFIGURE_COMMAND      ${CMAKE_COMMAND} -E echo "Configuration step skipped: using win32\\Makefile"
					BUILD_COMMAND          ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					TEST_COMMAND           ${CMAKE_MAKE_PROGRAM} test
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

# ====================================================================================================================================
# Net::SSLeay: needs openssl that needs nasm + zlib + post-installation of openssl libraries near Net::SSLeay
# Also openssl test suite can use Win32::API, so we depend on it
# ====================================================================================================================================
ExternalProject_Add(nasm
                    CMAKE_ARGS             -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DEPENDS                perl-core
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/nasm-${NASM_VERSION}.tar.gz
					#
					# Mkfiles/msvc.mak bug, c.f. https://forum.nasm.us/index.php?topic=2746.msg12335#msg12335
					#
					PATCH_COMMAND          ${Patch_EXECUTABLE} Mkfiles/msvc.mak ${PROJECT_SOURCE_DIR}/patches/nasm_msvc_mak.diff
					#
					# It needs Font::TTF Sort::Versions perl modules as per the doc
					#
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl Font::TTF Sort::Versions
					BUILD_COMMAND          ${CMAKE_COMMAND} -E rm -f asm/warnings.time
					COMMAND                ${CMAKE_COMMAND} -E touch asm/warnings.time
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} -f Mkfiles/msvc.mak
					INSTALL_COMMAND        ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E copy nasm.exe           ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E copy ndisasm.exe        ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/ldrdf.exe    ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2bin.exe  ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2com.exe  ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2ihx.exe  ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2ith.exe  ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2srec.exe ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdfdump.exe  ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdflib.exe   ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdx.exe      ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/license/nasm
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE            ${PERL_INST_DIR}/c/license/nasm
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy nasm.1             ${PERL_INST_DIR}/c/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy ndisasm.1          ${PERL_INST_DIR}/c/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/ldrdf.1      ${PERL_INST_DIR}/c/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2bin.1    ${PERL_INST_DIR}/c/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2com.1    ${PERL_INST_DIR}/c/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2ihx.1    ${PERL_INST_DIR}/c/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2ith.1    ${PERL_INST_DIR}/c/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2srec.1   ${PERL_INST_DIR}/c/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdfdump.1    ${PERL_INST_DIR}/c/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdflib.1     ${PERL_INST_DIR}/c/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdx.1        ${PERL_INST_DIR}/c/man/man1
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/lib
					COMMAND                ${CMAKE_COMMAND} -E copy libnasm.lib        ${PERL_INST_DIR}/c/lib
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/librdoff.lib ${PERL_INST_DIR}/c/lib
					#
					# No test target in nasm makefile
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE        TRUE)

add_custom_target(perl-win32-api DEPENDS perl-core COMMAND ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl Win32::API)
ExternalProject_Add(zlib
					#
					# We need to set RelWithDebInfo so that the library name is predictable: zlibstatic.lib instead of zlibstaticd.lib
					#
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/zlib-${ZLIB_VERSION}.tar.gz
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/license/zlib
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE            ${PERL_INST_DIR}/c/license/zlib
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE        TRUE)

#
# Why does is not work ?
# COMMAND                $<IF:$<STREQUAL:"${OPENSSL_VERSION}","3.0.5">,"${Patch_EXECUTABLE} util/perl/TLSProxy/Proxy.pm b/util/perl/TLSProxy/Proxy.pm ${PROJECT_SOURCE_DIR}/openssl-3.0.5-util-perl-TLSProxy-Proxy.diff",${CMAKE_COMMAND} -E echo "Not applicable: openssl-3.0.5-util-perl-TLSProxy-Proxy.diff">
#
if (${OPENSSL_VERSION} STREQUAL "3.0.5")
  set (OPENSLL_PATCH_COMMAND ${Patch_EXECUTABLE} util/perl/TLSProxy/Proxy.pm ${PROJECT_SOURCE_DIR}/patches/openssl-3.0.5-util-perl-TLSProxy-Proxy.diff)
else ()
  set (OPENSLL_PATCH_COMMAND ${CMAKE_COMMAND} -E echo "No patch for version ${OPENSSL_VERSION}")
endif ()

ExternalProject_Add(openssl
					DEPENDS                nasm perl-win32-api zlib
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/openssl-${OPENSSL_VERSION}.tar.gz
					PATCH_COMMAND          ${OPENSLL_PATCH_COMMAND}
					CONFIGURE_COMMAND      ${CMAKE_COMMAND} -E env LDFLAGS=${OPENSSL_LDFLAGS} ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl Configure --prefix=${PERL_C_INST_DIR_DOS} --openssldir=${PERL_C_INST_DIR_DOS}\\SSL --with-zlib-include=${PERL_C_INCLUDE_INST_DIR_DOS} --with-zlib-lib=${PERL_C_LIB_INST_DIR_DOS}\\zlibstatic.lib zlib enable-camellia enable-seed enable-rfc3779 enable-cms enable-md2 enable-rc5 enable-fips enable-weak-ssl-ciphers ${OPENSSL_VC}
					BUILD_COMMAND          ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/license/openssl
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE.txt        ${PERL_INST_DIR}/c/license/openssl
					TEST_COMMAND           ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} test
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

add_custom_target(perl-net-ssleay
				  DEPENDS                  perl-core openssl
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl CHRISN/Net-SSLeay-${PERL_NET_SSLEAY_VERSION}.tar.gz
				  #
				  # Post-install: copy openssl libraries near Net::SSLeay
				  #
				  COMMAND                  ${CMAKE_COMMAND} -E copy ${PERL_INST_DIR}/c/bin/libcrypto-3.dll ${PERL_INST_DIR}/site/lib/auto/Net/SSLeay
				  COMMAND                  ${CMAKE_COMMAND} -E copy ${PERL_INST_DIR}/c/bin/libcrypto-3.pdb ${PERL_INST_DIR}/site/lib/auto/Net/SSLeay
				  COMMAND                  ${CMAKE_COMMAND} -E copy ${PERL_INST_DIR}/c/bin/libssl-3.dll ${PERL_INST_DIR}/site/lib/auto/Net/SSLeay
				  COMMAND                  ${CMAKE_COMMAND} -E copy ${PERL_INST_DIR}/c/bin/libssl-3.pdb ${PERL_INST_DIR}/site/lib/auto/Net/SSLeay
				  )

add_custom_target(perl-io-socket-ssl DEPENDS perl-net-ssleay COMMAND ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl IO::Socket::SSL)

# ====================================================================================================================================
# Win32::GUI: needs freeimage + post-installation of freeimage library near Win32::GUI
# ====================================================================================================================================
ExternalProject_Add(freeimage
                    CMAKE_ARGS             -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/FreeImage-${FREEIMAGE_VERSION}.tar.gz
				    COMMAND                ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/FreeImage_CMakeLists.txt freeimage/CMakeLists.txt
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE        TRUE)

add_custom_target(perl-win32-gui
				  DEPENDS                  perl-core freeimage
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl KMX/Win32-GUI-${PERL_WIN32_GUI_VERSION}.tar.gz
				  #
				  # Post-install: copy freeimage library near Win32::GUI::DIBitmap
				  #
				  COMMAND                  ${CMAKE_COMMAND} -E copy ${PERL_INST_DIR}/c/bin/freeimage.dll ${PERL_INST_DIR}/site/lib/auto/Win32/GUI/DIBitmap
				  )

# ===========================================================
# External project expat
# ===========================================================
set (EXPAT_VERSION_UNDERSCORE ${EXPAT_VERSION})
string(REGEX REPLACE "\\." "_" EXPAT_VERSION_UNDERSCORE ${EXPAT_VERSION_UNDERSCORE})
ExternalProject_Add(expat
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/expat-${EXPAT_VERSION}.tar.gz
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/license/expat
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING            ${PERL_INST_DIR}/c/license/expat
					#
					# XML::Expat want expat.lib and expat.dll, not libexpat.lib or libexpat.dll
					#
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)
add_custom_target(perl-xml-parser
				  DEPENDS                  perl-core expat
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl XML::Parser
				  #
				  # Post-install: copy openssl libraries near Net::SSLeay
				  #
				  COMMAND                  ${CMAKE_COMMAND} -E copy ${PERL_INST_DIR}/c/bin/libexpat.dll ${PERL_INST_DIR}/site/lib/auto/XML/Parser/Expat
				  )

# ===========================================================
# External project fribidi
# ===========================================================
ExternalProject_Add(fribidi
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/fribidi-${FRIBIDI_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/fribidi_CMakeLists.txt CMakeLists.txt
					BUILD_COMMAND          ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/license/fribidi
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING            ${PERL_INST_DIR}/c/license/fribidi
					TEST_COMMAND           ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} test
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project libiconv
# ===========================================================
ExternalProject_Add(libiconv
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libiconv-${LIBICONV_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/libiconv_CMakeLists.txt CMakeLists.txt
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/libiconv-${LIBICONV_VERSION}/libiconv-${LIBICONV_VERSION}.patch
					BUILD_COMMAND          ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/license/libiconv
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING            ${PERL_INST_DIR}/c/license/libiconv
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project datrie
# ===========================================================
ExternalProject_Add(datrie
					DEPENDS libiconv
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/datrie-${DATRIE_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/datrie_CMakeLists.txt CMakeLists.txt
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/datrie-${DATRIE_VERSION}/datrie-${DATRIE_VERSION}.diff
					BUILD_COMMAND          ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/license/datrie
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING            ${PERL_INST_DIR}/c/license/datrie
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project thai
# ===========================================================
ExternalProject_Add(thai
					# Even if we know that datrie already depends on iconv I add it explicitly to show that the thai tests rely on it
					DEPENDS                datrie libiconv
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/thai-${THAI_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/thai_CMakeLists.txt CMakeLists.txt
					# https://github.com/fanc999/thai patches
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/thai-${THAI_VERSION}/thai-${THAI_VERSION}-fanc999.diff
					# Utf-8 test file: portable source using bytes + portability fix
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/thai-${THAI_VERSION}/thai-${THAI_VERSION}-test_thbrk.diff
					# We need perl environment for our pkgconfig - we intentionally say cmake and not ${CMAKE_PROGRAM}
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					BUILD_COMMAND          ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/license/thai
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING            ${PERL_INST_DIR}/c/license/thai
					TEST_EXCLUDE_FROM_MAIN FALSE
					# We need perl environment for the path
					TEST_COMMAND           ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} test
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project Giflib
# ===========================================================
ExternalProject_Add(giflib
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/giflib-${GIFLIB_VERSION}.tar.gz
					#
					# Apply first debian patches
					#
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/giflib-${GIFLIB_VERSION}/debian/patches/fix-get-args-segment-violation.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/giflib-${GIFLIB_VERSION}/debian/patches/install-only-distributed-binaries-manuals.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/giflib-${GIFLIB_VERSION}/debian/patches/fix-spelling-errors-on-doc-pages.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/giflib-${GIFLIB_VERSION}/debian/patches/recover-giffilter-docs.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/giflib-${GIFLIB_VERSION}/debian/patches/add-gifsponge-docs.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/giflib-${GIFLIB_VERSION}/debian/patches/30_link_utils_dynamically.diff
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/giflib-${GIFLIB_VERSION}/debian/patches/giflib_quantize.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/giflib-${GIFLIB_VERSION}/debian/patches/dont-spoil-tests-with-stderr.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/giflib-${GIFLIB_VERSION}/debian/patches/giflib_quantize-header.patch
					#
					# The our diff on top of that
					#
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/giflib-${GIFLIB_VERSION}/giflib-5.2.1.diff
					#
					# Continue...
					#
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/license/giflib
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/license/giflib
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE        TRUE
					)

# ===========================================================
# External project SDL2
# ===========================================================
ExternalProject_Add(SDL2
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/SDL2-${SDL2_VERSION}.tar.gz
					#
					# No test target
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					#
					# Hey SDL2 CMakeLists.txt is checking that we build in source or not
					#
					BUILD_IN_SOURCE        FALSE)

# ===========================================================
# External project sdl12-compat
# ===========================================================
ExternalProject_Add(sdl12-compat
					DEPENDS                SDL2
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/sdl12-compat-${SDL12_COMPAT_VERSION}.tar.gz
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project libde265
# ===========================================================
ExternalProject_Add(libde265
					DEPENDS                sdl12-compat
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libde265-${LIBDE265_VERSION}.tar.gz
					#
					# No test target
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project x265
# ===========================================================
ExternalProject_Add(x265
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					SOURCE_SUBDIR          source
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/x265-${X265_VERSION}.tar.gz
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project aom
# ===========================================================
ExternalProject_Add(aom
					DEPENDS                nasm
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/aom-${AOM_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/aom-${AOM_VERSION}/no-force-inline.patch
					# We need perl environment for our pkgconfig - we intentionally say cmake and not ${CMAKE_PROGRAM}
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -DBUILD_SHARED_LIBS=ON ${CMAKE_CURRENT_BINARY_DIR}/aom-prefix/src/aom
					#
					# No test target
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					#
					# Hey aom CMakeLists.txt is checking that we build in source or not
					#
					BUILD_IN_SOURCE        FALSE)

# ===========================================================
# External project libjpeg-turbo
# ===========================================================
ExternalProject_Add(libjpeg-turbo
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libjpeg-turbo-${LIBJPEG_TURBO_VERSION}.tar.gz
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					#
					# Hey aom CMakeLists.txt is checking that we build in source or not
					#
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project libheif
# ===========================================================
ExternalProject_Add(libheif
					DEPENDS                libde265 x265 aom libjpeg-turbo
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libheif-${LIBHEIF_VERSION}.tar.gz
					#
					# No test target
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project libpng
# ===========================================================
ExternalProject_Add(libpng
					DEPENDS                zlib
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libpng-${LIBPNG_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/libpng-${LIBPNG_VERSION}/install-pkgconfig.patch
					#
					# Test suite will require access to zlib
					#
					TEST_COMMAND           ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} test
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					#
					# Hey aom CMakeLists.txt is checking that we build in source or not
					#
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project libdeflate
# ===========================================================
ExternalProject_Add(libdeflate
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libdeflate-${LIBDEFLATE_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/libdeflate_CMakeLists.txt CMakeLists.txt
					#
					# No test target
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project jbigkit
# ===========================================================
ExternalProject_Add(jbigkit
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/jbigkit-${JBIGKIT_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/jbigkit_CMakeLists.txt CMakeLists.txt
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/jbigkit-${JBIGKIT_VERSION}/dllimportexport.patch
					#
					# No test target
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project tiff
# ===========================================================
ExternalProject_Add(tiff
					DEPENDS                zlib libjpeg-turbo libdeflate jbigkit
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/tiff-${TIFF_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/add_v4.4.0.html_to_docfiles.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/CVE-2022-2056_CVE-2022-2057_CVE-2022-2058.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/CVE-2022-34526.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/CVE-2022-3597_CVE-2022-3626_CVE-2022-3627.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/CVE-2022-3570.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/CVE-2022-3599.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/CVE-2022-3598.patch
					#
					# Test suite will require access to zlib
					#
					# TEST_COMMAND           ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} test
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					#
					# Hey aom CMakeLists.txt is checking that we build in source or not
					#
					BUILD_IN_SOURCE        TRUE)

add_custom_target(perl-pkgconfig
				  DEPENDS                  perl-core
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl PkgConfig
				  )
add_custom_target(perl-prima
				  DEPENDS                  perl-pkgconfig fribidi thai giflib libheif libjpeg-turbo libpng tiff
				  # COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl Prima
				  )

# ====================================================================================================================================
# We consider that perl is ready when modules that require special post-install rules or are dependant on external projets are done:
# Net::SSleay
# Win32::GUI
# XML::Parser
# Win32::Prima
# ====================================================================================================================================
add_custom_target(perl               DEPENDS perl-io-socket-ssl perl-win32-gui perl-xml-parser)

# ====================================================================================================================================
# From now on, we just create rules for all the extra packages
# ====================================================================================================================================
SET (PACKAGES
	Archive::Zip               # Few old distributions are packaged as ZIP, so get Archive::Zip asap
	Log::Log4perl
    Win32::WQL
	Win32::ADO
	# Win32::API               Done with perl-win32-api
	Win32::ASP
	Win32::CLR
	Win32::Env
	# Win32::GUI               Done with perl-win32-gui
	Win32::HTA
	Win32::IPC
	Win32::Job
	# Win32::Ldd               Does not compile + apparently buggy https://github.com/LRN/ntldd/issues/5
	Win32::MMF
	Win32::OLE
	Win32::File
	Win32::INET
	Win32::MBCS
	Win32::MIDI
	# Win32::Mock             Too old, too hacky, not needed IMHO
	Win32::ODBC
	Win32::Pipe
	# Win32::RASE             Too old, too hacky, not needed IMHO
	Win32::SDDL
	Win32::Scsv
	Win32::Wlan
	# Win32::Fmode            Too old, too hacky, not needed IMHO
	# Win32::Netsh            Tests too buggy
	# Win32::SAPI4            Test fail I do not really understand - has to do the registry ?
	Win32::SAPI5
	Win32::Sound
	Win32::Vcpkg
	# Win32::Watir            Test fail I do not really understand
	Win32::pwent 
	# Win32::Snarl            !?
	Config::Win32
	# Win32::ActAcc           !?
	Win32::Daemon
	Win32::FileOp             # TAKE CARE Popup a window
	Win32::JobAdd
	Win32::Locale
	# Win32::MprApi
	Win32::PEFile
	# Win32:Ldd              # Cannot compile (needs gcc?)
	# Win32::Packer          # Needs Win32::Ldd
	Win32::Readch
	# Win32::Script          # Interactive...
	Win32::Status
	Win32::Uptime
	Win32::Useful
	# Win32::Lanman          # So bad package - I just give up
	# Win32::DBIODBC         # It is part of DBI
	Win32::AbsPath
	Win32::AutoItX
	Win32::Capture
	Win32::Console
	# Win32::Setupsup        # Buggy
	# Win32::CtrlGUI         # Depends on Win32::Setupsup
	Win32::DirSize
	# Win32::Elevate         # Test fails, too dangerous, etc.
	Win32::Getppid
	Win32::GuiTest           # TAKE CARE Popup notepad windows
	# Win32::IntAuth         # SAPI4 + need to install things I do not want
	Win32::MinXSLT
	# Win32::NetName         # Depends on Win32::Lanman that I do not install
	Win32::NetSend
	Win32::PerfLib
	Win32::PerfMon
	Win32::Printer
	Win32::ProcFarm::Port    # Damned, has to install a sublib of it, Win32::ProcFarm standalone is not installable
	Win32::Process
	Win32::Service
	Win32::Symlink
	Win32::SysTray
	Win32::TarUtil
	Win32::Tracert
	Win32::Unicode
	Win32::Guidgen
	Win32::Wingraph
	Win32::Autoglob
	# Win32::Codepage       # Tests too buggy for a module that does not look very useful to me
	Win32::Detached
	Win32::EventLog
	# Win32::FileTime       # Unmaintained and not useful IMHO
	# Win32::FindFile       # Unmaintained and not useful IMHO
	# Win32::GUIRobot       TO DO DEPENDENCY ON PRIMA BUT PRIMA FAILURE
)
foreach(package ${PACKAGES})
  # Transform package to a rule like perl-xxx
  SET(rule "perl-${package}")
  string(TOLOWER ${rule} rule)
  string(REPLACE "::" "-" rule ${rule})
  add_custom_target(${rule} ALL DEPENDS perl COMMAND ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl ${package})
endforeach()
