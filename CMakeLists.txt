#
# Example: cmake -G "NMake Makefiles"
#
# Note that perl had real problems with symlink on MSWin32 between 5.34 and
# 5.36 - this is fixed since 5.37.4, therefore building a 5.37.4 version at
# least is recommended.
#
# We use distproprefs that will require patch.exe. We use find_package(Patch) that
# normally detect that you have GIT installed and gets patch.exe from it.
# It is highty not recommended to do:
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

set (PERL_VERSION_DEFAULT                  5.37.6)
set (OPENSSL_VERSION_DEFAULT               3.0.5)
set (NASM_VERSION_DEFAULT                  2.15.05)
set (PERL_NET_SSLEAY_VERSION_DEFAULT       1.93_01)
set (PERL_WIN32_GUI_VERSION_DEFAULT        1.14)
set (PERL_XML_LIBXML_VERSION_DEFAULT       2.0208)
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
set (LERC_VERSION_DEFAULT                  4.0.0)
set (XZ_VERSION_DEFAULT                    5.2.8)
set (ZSTD_VERSION_DEFAULT                  1.5.2)
set (LIBWEBP_VERSION_DEFAULT               1.2.4)
set (GDIPLUS_VERSION_DEFAULT               prima)
set (LIBXPM_VERSION_DEFAULT                3.5.14)
set (FREEGLUT_VERSION_DEFAULT              3.4.0)
set (LIBXML2_VERSION_DEFAULT               2.9.12)
set (LIBPCAP_VERSION_DEFAULT               1.10.1)
set (WINFLEXBISON_VERSION_DEFAULT          2.5.25)
set (BZIP2_VERSION_DEFAULT                 2d8393924b9f3e014000c7420c7da7c3ddb74e2c)
set (BROTLI_VERSION_DEFAULT                1.0.9)
set (FREETYPE_VERSION_DEFAULT              2.12.1)
set (HARFBUZZ_VERSION_DEFAULT              6.0.0)
set (HIGHWAY_VERSION_DEFAULT               1.0.2)
set (LCMS2_VERSION_DEFAULT                 2.14)
set (IMATH_VERSION_DEFAULT                 3.1.6)
set (OPENEXR_VERSION_DEFAULT               3.1.5)
set (LIBAVIF_VERSION_DEFAULT               0.11.1)
set (LIBJXL_VERSION_DEFAULT                0.7.0)
set (GRAPHICSMAGICK_VERSION_DEFAULT        1.3.38)

set (PERL_INST_DRV                 ${PERL_INST_DRV_DEFAULT}                 CACHE STRING "perl installation drive")
set (PERL_VERSION                  ${PERL_VERSION_DEFAULT}                  CACHE STRING "perl version")
set (OPENSSL_VERSION               ${OPENSSL_VERSION_DEFAULT}               CACHE STRING "openssl version")
set (NASM_VERSION                  ${NASM_VERSION_DEFAULT}                  CACHE STRING "nasm version")
set (PERL_NET_SSLEAY_VERSION       ${PERL_NET_SSLEAY_VERSION_DEFAULT}       CACHE STRING "specific Net::SSLeay version")
set (PERL_WIN32_GUI_VERSION        ${PERL_WIN32_GUI_VERSION_DEFAULT}        CACHE STRING "specific Win32::GUI version")
set (PERL_XML_LIBXML_VERSION       ${PERL_XML_LIBXML_VERSION_DEFAULT}       CACHE STRING "specific XML::LibXML version")
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
set (LERC_VERSION                  ${LERC_VERSION_DEFAULT}                  CACHE STRING "lerc version")
set (XZ_VERSION                    ${XZ_VERSION_DEFAULT}                    CACHE STRING "xz version")
set (ZSTD_VERSION                  ${ZSTD_VERSION_DEFAULT}                  CACHE STRING "zstd version")
set (LIBWEBP_VERSION               ${LIBWEBP_VERSION_DEFAULT}               CACHE STRING "libwebp version")
set (GDIPLUS_VERSION               ${GDIPLUS_VERSION_DEFAULT}               CACHE STRING "gdiplus version")
set (LIBXPM_VERSION                ${LIBXPM_VERSION_DEFAULT}                CACHE STRING "libXpm version")
set (FREEGLUT_VERSION              ${FREEGLUT_VERSION_DEFAULT}              CACHE STRING "freeglut version")
set (LIBXML2_VERSION               ${LIBXML2_VERSION_DEFAULT}               CACHE STRING "libxml2 version")
set (LIBPCAP_VERSION               ${LIBPCAP_VERSION_DEFAULT}               CACHE STRING "libpcap version")
set (WINFLEXBISON_VERSION          ${WINFLEXBISON_VERSION_DEFAULT}          CACHE STRING "winflexbison version")
set (BZIP2_VERSION                 ${BZIP2_VERSION_DEFAULT}                 CACHE STRING "bzip2 version")
set (BROTLI_VERSION                ${BROTLI_VERSION_DEFAULT}                CACHE STRING "brotli version")
set (FREETYPE_VERSION              ${FREETYPE_VERSION_DEFAULT}              CACHE STRING "freetype version")
set (HARFBUZZ_VERSION              ${HARFBUZZ_VERSION_DEFAULT}              CACHE STRING "harfbuzz version")
set (HIGHWAY_VERSION               ${HIGHWAY_VERSION_DEFAULT}               CACHE STRING "highway version")
set (LCMS2_VERSION                 ${LCMS2_VERSION_DEFAULT}                 CACHE STRING "lcms2 version")
set (IMATH_VERSION                 ${IMATH_VERSION_DEFAULT}                 CACHE STRING "imath version")
set (OPENEXR_VERSION               ${OPENEXR_VERSION_DEFAULT}               CACHE STRING "openexr version")
set (LIBAVIF_VERSION               ${LIBAVIF_VERSION_DEFAULT}               CACHE STRING "libavif version")
set (LIBJXL_VERSION                ${LIBJXL_VERSION_DEFAULT}                CACHE STRING "libjxl version")
set (GRAPHICSMAGICK_VERSION        ${GRAPHICSMAGICK_VERSION_DEFAULT}        CACHE STRING "GraphicsMagick version")

set_property (CACHE PERL_INST_DRV                 PROPERTY STRINGS ${drives} )
set_property (CACHE PERL_VERSION                  PROPERTY STRINGS ${PERL_VERSIONS})
set_property (CACHE OPENSSL_VERSION               PROPERTY STRINGS ${OPENSSL_VERSION_DEFAULT})
set_property (CACHE NASM_VERSION                  PROPERTY STRINGS ${NASM_VERSION_DEFAULT})
set_property (CACHE PERL_NET_SSLEAY_VERSION       PROPERTY STRINGS ${PERL_NET_SSLEAY_VERSION_DEFAULT})
set_property (CACHE PERL_WIN32_GUI_VERSION        PROPERTY STRINGS ${PERL_WIN32_GUI_VERSION_DEFAULT})
set_property (CACHE PERL_XML_LIBXML_VERSION       PROPERTY STRINGS ${PERL_XML_LIBXML_VERSION_DEFAULT})
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
set_property (CACHE LERC_VERSION                  PROPERTY STRINGS ${LERC_VERSION_DEFAULT})
set_property (CACHE XZ_VERSION                    PROPERTY STRINGS ${XZ_VERSION_DEFAULT})
set_property (CACHE ZSTD_VERSION                  PROPERTY STRINGS ${ZSTD_VERSION_DEFAULT})
set_property (CACHE LIBWEBP_VERSION               PROPERTY STRINGS ${LIBWEBP_VERSION_DEFAULT})
set_property (CACHE GDIPLUS_VERSION               PROPERTY STRINGS ${GDIPLUS_VERSION_DEFAULT})
set_property (CACHE LIBXPM_VERSION                PROPERTY STRINGS ${LIBXPM_VERSION_DEFAULT})
set_property (CACHE FREEGLUT_VERSION              PROPERTY STRINGS ${FREEGLUT_VERSION_DEFAULT})
set_property (CACHE LIBXML2_VERSION               PROPERTY STRINGS ${LIBXML2_VERSION_DEFAULT})
set_property (CACHE LIBPCAP_VERSION               PROPERTY STRINGS ${LIBPCAP_VERSION_DEFAULT})
set_property (CACHE WINFLEXBISON_VERSION          PROPERTY STRINGS ${WINFLEXBISON_VERSION_DEFAULT})
set_property (CACHE BZIP2_VERSION                 PROPERTY STRINGS ${BZIP2_VERSION_DEFAULT})
set_property (CACHE BROTLI_VERSION                PROPERTY STRINGS ${BROTLI_VERSION_DEFAULT})
set_property (CACHE FREETYPE_VERSION              PROPERTY STRINGS ${FREETYPE_VERSION_DEFAULT})
set_property (CACHE HARFBUZZ_VERSION              PROPERTY STRINGS ${HARFBUZZ_VERSION_DEFAULT})
set_property (CACHE HIGHWAY_VERSION               PROPERTY STRINGS ${HIGHWAY_VERSION_DEFAULT})
set_property (CACHE LCMS2_VERSION                 PROPERTY STRINGS ${LCMS2_VERSION_DEFAULT})
set_property (CACHE IMATH_VERSION                 PROPERTY STRINGS ${IMATH_VERSION_DEFAULT})
set_property (CACHE OPENEXR_VERSION               PROPERTY STRINGS ${OPENEXR_VERSION_DEFAULT})
set_property (CACHE LIBAVIF_VERSION               PROPERTY STRINGS ${LIBAVIF_VERSION_DEFAULT})
set_property (CACHE LIBJXL_VERSION                PROPERTY STRINGS ${LIBJXL_VERSION_DEFAULT})
set_property (CACHE GRAPHICSMAGICK_VERSION        PROPERTY STRINGS ${GRAPHICSMAGICK_VERSION_DEFAULT})

message (STATUS "===================================")
message (STATUS "Version of Perl                   : ${PERL_VERSION}")
message (STATUS "===================================")
message (STATUS "                                   ")
message (STATUS "===================================")
message (STATUS "Perl packages forced versions      ")
message (STATUS "===================================")
message (STATUS "Version of Net::SSLeay            : ${PERL_NET_SSLEAY_VERSION}")
message (STATUS "Version of Win32::GUI             : ${PERL_WIN32_GUI_VERSION}")
message (STATUS "Version of XML::LibXML            : ${PERL_XML_LIBXML_VERSION}")
message (STATUS "                                   ")
message (STATUS "===================================")
message (STATUS "External packages                  ")
message (STATUS "===================================")
message (STATUS "Version of nasm                   : ${NASM_VERSION}")
message (STATUS "Version of openssl                : ${OPENSSL_VERSION}")
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
message (STATUS "Version of lerc                   : ${LERC_VERSION}")
message (STATUS "Version of xz                     : ${XZ_VERSION}")
message (STATUS "Version of zstd                   : ${ZSTD_VERSION}")
message (STATUS "Version of libwebp                : ${LIBWEBP_VERSION}")
message (STATUS "Version of gdiplus                : ${GDIPLUS_VERSION}")
message (STATUS "Version of libXpm                 : ${LIBXPM_VERSION}")
message (STATUS "Version of freeglut               : ${FREEGLUT_VERSION}")
message (STATUS "Version of libxml2                : ${LIBXML2_VERSION}")
message (STATUS "Version of libpcap                : ${LIBPCAP_VERSION}")
message (STATUS "Version of winflexbison           : ${WINFLEXBISON_VERSION}")
message (STATUS "Version of bzip2                  : ${BZIP2_VERSION}")
message (STATUS "Version of brotli                 : ${BROTLI_VERSION}")
message (STATUS "Version of freetype               : ${FREETYPE_VERSION}")
message (STATUS "Version of harfbuzz               : ${HARFBUZZ_VERSION}")
message (STATUS "Version of highway                : ${HIGHWAY_VERSION}")
message (STATUS "Version of lcms2                  : ${LCMS2_VERSION}")
message (STATUS "Version of imath                  : ${IMATH_VERSION}")
message (STATUS "Version of openexr                : ${OPENEXR_VERSION}")
message (STATUS "Version of libavif                : ${LIBAVIF_VERSION}")
message (STATUS "Version of libjxl                 : ${LIBJXL_VERSION}")
message (STATUS "Version of GraphicsMagick         : ${GRAPHICSMAGICK_VERSION}")
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

set (PERL_C_PKGCONFIG_INST_DIR "${PERL_INST_DIR}/c/lib/pkgconfig")
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
REM For XML::LibXML
REM
SET PERL_XML_LIBXML_CFLAGS=-I${PERL_C_INCLUDE_INST_DIR_DOS}

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

REM
REM For Prima
REM
SET PRIMA_EXTRA_CCFLAGS=-I${PERL_C_INCLUDE_INST_DIR_DOS}

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
if (INSTALL_REQUIRED_SYSTEM_LIBRARIES)
	#
	# This will install MSCV runtime libraries, that we should not
	# for license point of view
	#
	set (CMAKE_BUILD_TYPE "RelWithDebInfo")
	set (CMAKE_INSTALL_PREFIX ${PERL_C_INST_DIR})
	foreach (_what CMAKE_BUILD_TYPE CMAKE_INSTALL_PREFIX)
		message(STATUS "Forcing ${_what} to ${${_what}}")
	endforeach ()
	include(InstallRequiredSystemLibraries)
endif ()

# ===========================================================
# External project perl-core
# ===========================================================
ExternalProject_Add(perl-core
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/perl-core-${PERL_VERSION}.tar.gz
					SOURCE_SUBDIR          win32
					PATCH_COMMAND          ${CMAKE_COMMAND} -E env ${PERLPATCH_BAT_DOS} ${REPLACE_VBS_DOS} ${PERL_CCTYPE} ${PERL_WIN64} ${PERL_INSTSUBDIR} ${PERL_INST_DRV}
					COMMAND                ${Patch_EXECUTABLE} inline.h                   ${PROJECT_SOURCE_DIR}/patches/perl-rt12986-inline.h.patch
					COMMAND                ${Patch_EXECUTABLE} win32/win32.c              ${PROJECT_SOURCE_DIR}/patches/perl-rt12986-win32-win32.c.patch
					COMMAND                ${Patch_EXECUTABLE} win32/win32.h              ${PROJECT_SOURCE_DIR}/patches/perl-rt12986-win32-win32.h.patch
					COMMAND                ${Patch_EXECUTABLE} win32/win32sck.c           ${PROJECT_SOURCE_DIR}/patches/perl-rt12986-win32-win32sck.c.patch
					COMMAND                ${Patch_EXECUTABLE} cpan/Win32API-File/File.pm ${PROJECT_SOURCE_DIR}/patches/Win32API-File-pr-15.patch
					COMMAND                ${Patch_EXECUTABLE} t/porting/customized.dat   ${PROJECT_SOURCE_DIR}/patches/Win32API-File-pr-15-impact-on-customized-dat.patch
					CONFIGURE_COMMAND      ${CMAKE_COMMAND} -E echo "Configuration step skipped: using win32\\Makefile"
					BUILD_COMMAND          ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					#
					# Install immediately Win32::API because our sitecustomize will depend on it
					#
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl Win32::API
					#
					# Activate sitecustomize
					#
					COMMAND                ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/sitecustomize.pl ${PERL_INST_DIR}/site/lib/sitecustomize.pl
					TEST_COMMAND           ${CMAKE_MAKE_PROGRAM} test
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

add_custom_target(perl-pkgconfig
				  DEPENDS                  perl-core
				  COMMAND                  ${CMAKE_COMMAND} -E env PERL_PKGCONFIG_BOOTSTRAP=1 ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl PkgConfig
				  )

#
# Even if this is not true for all other rules, we now systematically depend on perl-pkgconfig instead of perl-core
#

add_custom_target(perl-font-ttf
				  DEPENDS                  perl-pkgconfig
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl Font::TTF
				  )

add_custom_target(perl-sort-versions
				  DEPENDS                  perl-pkgconfig
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl Sort::Versions
				  )

add_custom_target(perl-win32-api
                  DEPENDS                  perl-pkgconfig
				  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl Win32::API)

#
# URI is very central and I observed that some modules depends on it but CPAN do not see this
#
add_custom_target(perl-uri
                  DEPENDS                  perl-pkgconfig
				  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl URI)

# ====================================================================================================================================
# Net::SSLeay: needs openssl
# Also openssl test suite can use Win32::API, so we depend on it
# ====================================================================================================================================
ExternalProject_Add(nasm
					DEPENDS                perl-pkgconfig perl-font-ttf perl-sort-versions
					CONFIGURE_COMMAND      ""
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/nasm-${NASM_VERSION}.tar.gz
					#
					# Mkfiles/msvc.mak bug, c.f. https://forum.nasm.us/index.php?topic=2746.msg12335#msg12335
					#
					PATCH_COMMAND          ${Patch_EXECUTABLE} Mkfiles/msvc.mak ${PROJECT_SOURCE_DIR}/patches/nasm_msvc_mak.diff
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
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/licenses/nasm
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE            ${PERL_INST_DIR}/c/licenses/nasm
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/share/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy nasm.1             ${PERL_INST_DIR}/c/share/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy ndisasm.1          ${PERL_INST_DIR}/c/share/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/ldrdf.1      ${PERL_INST_DIR}/c/share/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2bin.1    ${PERL_INST_DIR}/c/share/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2com.1    ${PERL_INST_DIR}/c/share/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2ihx.1    ${PERL_INST_DIR}/c/share/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2ith.1    ${PERL_INST_DIR}/c/share/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdf2srec.1   ${PERL_INST_DIR}/c/share/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdfdump.1    ${PERL_INST_DIR}/c/share/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdflib.1     ${PERL_INST_DIR}/c/share/man/man1
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/rdx.1        ${PERL_INST_DIR}/c/share/man/man1
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/lib
					COMMAND                ${CMAKE_COMMAND} -E copy libnasm.lib        ${PERL_INST_DIR}/c/lib
					COMMAND                ${CMAKE_COMMAND} -E copy rdoff/librdoff.lib ${PERL_INST_DIR}/c/lib
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# No test target in nasm makefile
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE        TRUE)

ExternalProject_Add(zlib
					DEPENDS                perl-pkgconfig
					#
					# We need to set RelWithDebInfo so that the library name is predictable: zlibstatic.lib instead of zlibstaticd.lib
					#
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/zlib-${ZLIB_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/zlib-${ZLIB_VERSION}/pkgconfig-install-path.patch
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/licenses/zlib
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE            ${PERL_INST_DIR}/c/licenses/zlib
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
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
					DEPENDS                perl-pkgconfig nasm perl-win32-api zlib
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/openssl-${OPENSSL_VERSION}.tar.gz
					PATCH_COMMAND          ${OPENSLL_PATCH_COMMAND}
					CONFIGURE_COMMAND      ${CMAKE_COMMAND} -E env LDFLAGS=${OPENSSL_LDFLAGS} ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl Configure --prefix=${PERL_C_INST_DIR_DOS} --openssldir=${PERL_C_INST_DIR_DOS}\\SSL --with-zlib-include=${PERL_C_INCLUDE_INST_DIR_DOS} --with-zlib-lib=${PERL_C_LIB_INST_DIR_DOS}\\zlibstatic.lib zlib enable-camellia enable-seed enable-rfc3779 enable-cms enable-md2 enable-rc5 enable-fips enable-weak-ssl-ciphers ${OPENSSL_VC}
					BUILD_COMMAND          ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/licenses/openssl
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE.txt        ${PERL_INST_DIR}/c/licenses/openssl
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					TEST_COMMAND           ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} test
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

add_custom_target(perl-net-ssleay
				  DEPENDS                  perl-pkgconfig openssl
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl CHRISN/Net-SSLeay-${PERL_NET_SSLEAY_VERSION}.tar.gz
				  )

add_custom_target(perl-io-socket-ssl
                  DEPENDS                  perl-net-ssleay
				  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl IO::Socket::SSL)

# ====================================================================================================================================
# Win32::GUI: needs freeimage + post-installation of freeimage library near Win32::GUI
# ====================================================================================================================================
ExternalProject_Add(freeimage
                    DEPENDS                perl-pkgconfig
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/FreeImage-${FREEIMAGE_VERSION}.tar.gz
				    COMMAND                ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/FreeImage/CMakeLists.txt freeimage/CMakeLists.txt
					INSTALL_COMMAND        ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/licenses/FreeImage
					COMMAND                ${CMAKE_COMMAND} -E copy license-fi.txt     ${PERL_INST_DIR}/c/licenses/FreeImage
					COMMAND                ${CMAKE_COMMAND} -E copy license-gplv2.txt  ${PERL_INST_DIR}/c/licenses/FreeImage
					COMMAND                ${CMAKE_COMMAND} -E copy license-gplv3.txt  ${PERL_INST_DIR}/c/licenses/FreeImage
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE        TRUE)

add_custom_target(perl-win32-gui
				  DEPENDS                  perl-pkgconfig freeimage
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl KMX/Win32-GUI-${PERL_WIN32_GUI_VERSION}.tar.gz
				  )

# ===========================================================
# External project expat
# ===========================================================
set (EXPAT_VERSION_UNDERSCORE ${EXPAT_VERSION})
string(REGEX REPLACE "\\." "_" EXPAT_VERSION_UNDERSCORE ${EXPAT_VERSION_UNDERSCORE})
ExternalProject_Add(expat
                    DEPENDS                perl-pkgconfig
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/expat-${EXPAT_VERSION}.tar.gz
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/licenses/expat
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING            ${PERL_INST_DIR}/c/licenses/expat
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)
add_custom_target(perl-xml-parser
				  DEPENDS                  perl-pkgconfig expat perl-uri
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl XML::Parser
				  )

# ===========================================================
# External project fribidi
# ===========================================================
ExternalProject_Add(fribidi
                    DEPENDS                perl-pkgconfig
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/fribidi-${FRIBIDI_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/fribidi/CMakeLists.txt CMakeLists.txt
					BUILD_COMMAND          ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/licenses/fribidi
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING            ${PERL_INST_DIR}/c/licenses/fribidi
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					TEST_COMMAND           ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} test
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project libiconv
# ===========================================================
ExternalProject_Add(libiconv
                    DEPENDS                perl-pkgconfig
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libiconv-${LIBICONV_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/libiconv/CMakeLists.txt CMakeLists.txt
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/libiconv-${LIBICONV_VERSION}/libiconv-${LIBICONV_VERSION}.patch
					BUILD_COMMAND          ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/licenses/libiconv
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING            ${PERL_INST_DIR}/c/licenses/libiconv
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project datrie
# ===========================================================
ExternalProject_Add(datrie
					DEPENDS                perl-pkgconfig libiconv
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/datrie-${DATRIE_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/datrie/CMakeLists.txt CMakeLists.txt
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/datrie-${DATRIE_VERSION}/datrie-${DATRIE_VERSION}.diff
					BUILD_COMMAND          ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/licenses/datrie
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING            ${PERL_INST_DIR}/c/licenses/datrie
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project thai
# ===========================================================
ExternalProject_Add(thai
					# Even if we know that datrie already depends on iconv I add it explicitly to show that the thai tests rely on it
					DEPENDS                perl-pkgconfig datrie libiconv
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/thai-${THAI_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/thai/CMakeLists.txt CMakeLists.txt
					# https://github.com/fanc999/thai patches
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/thai-${THAI_VERSION}/thai-${THAI_VERSION}-fanc999.diff
					# Utf-8 test file: portable source using bytes + portability fix
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/thai-${THAI_VERSION}/thai-${THAI_VERSION}-test_thbrk.diff
					BUILD_COMMAND          ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/licenses/thai
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING            ${PERL_INST_DIR}/c/licenses/thai
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					TEST_EXCLUDE_FROM_MAIN FALSE
					# We need perl environment for the path
					TEST_COMMAND           ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} test
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project Giflib
# ===========================================================
ExternalProject_Add(giflib
                    DEPENDS                perl-pkgconfig
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
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
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/giflib-${GIFLIB_VERSION}/giflib-5.2.1-remove-const.diff
					#
					# Continue...
					#
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/giflib
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/licenses/giflib
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE        TRUE
					)

# ===========================================================
# External project SDL2
# ===========================================================
ExternalProject_Add(SDL2
                    DEPENDS                perl-pkgconfig
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" ../SDL2
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/SDL2-${SDL2_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/SDL2-${SDL2_VERSION}/cmake-install-path.patch
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/SDL2
					COMMAND                ${CMAKE_COMMAND} -E copy ../SDL2/LICENSE.txt  ${PERL_INST_DIR}/c/licenses/SDL2
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
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
					DEPENDS                perl-pkgconfig SDL2
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/sdl12-compat-${SDL12_COMPAT_VERSION}.tar.gz
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/sdl12-compat
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE.txt          ${PERL_INST_DIR}/c/licenses/sdl12-compat
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project libde265
# ===========================================================
ExternalProject_Add(libde265
					DEPENDS                perl-pkgconfig sdl12-compat
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libde265-${LIBDE265_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/libde265-${LIBDE265_VERSION}/install-pc.diff
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/libde265
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/licenses/libde265
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
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
                    DEPENDS                perl-pkgconfig nasm
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -DCMAKE_ASM_NASM_FLAGS=-w-macro-params-legacy .
					SOURCE_SUBDIR          source
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/x265-${X265_VERSION}.tar.gz
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/x265
					COMMAND                ${CMAKE_COMMAND} -E copy ../COPYING           ${PERL_INST_DIR}/c/licenses/x265
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project aom
# ===========================================================
ExternalProject_Add(aom
					DEPENDS                perl-pkgconfig nasm perl-pkgconfig
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -DBUILD_SHARED_LIBS=ON ../aom
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/aom-${AOM_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/aom-${AOM_VERSION}/no-force-inline.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/aom-${AOM_VERSION}/VS2015-_mm256_extract_epi16-and-alignment-errors.patch
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/aom
					COMMAND                ${CMAKE_COMMAND} -E copy ../aom/LICENSE       ${PERL_INST_DIR}/c/licenses/aom
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
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
					DEPENDS                perl-pkgconfig nasm
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libjpeg-turbo-${LIBJPEG_TURBO_VERSION}.tar.gz
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/libjpeg-turbo
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE.md           ${PERL_INST_DIR}/c/licenses/libjpeg-turbo
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
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
					DEPENDS                perl-pkgconfig libde265 x265 aom libjpeg-turbo
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libheif-${LIBHEIF_VERSION}.tar.gz
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/libheif
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/licenses/libheif
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
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
					DEPENDS                perl-pkgconfig zlib
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libpng-${LIBPNG_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/libpng-${LIBPNG_VERSION}/install-pkgconfig-and-cmake.patch
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/libpng
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE              ${PERL_INST_DIR}/c/licenses/libpng
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
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
                    DEPENDS                perl-pkgconfig
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libdeflate-${LIBDEFLATE_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/libdeflate/CMakeLists.txt CMakeLists.txt
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/libdeflate
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/licenses/libdeflate
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
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
                    DEPENDS                perl-pkgconfig
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/jbigkit-${JBIGKIT_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/jbigkit/CMakeLists.txt CMakeLists.txt
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/jbigkit-${JBIGKIT_VERSION}/dllimportexport.patch
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/jbigkit
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/licenses/jbigkit
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# No test target
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project lerc
# ===========================================================
ExternalProject_Add(lerc
                    DEPENDS                perl-pkgconfig
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -DBUILD_SHARED_LIBS=ON .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/lerc-${LERC_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/lerc-${LERC_VERSION}/std-greater.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/lerc-${LERC_VERSION}/std-min.patch
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/lerc
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE              ${PERL_INST_DIR}/c/licenses/lerc
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# No test target
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project xz
# ===========================================================
ExternalProject_Add(xz
                    DEPENDS                perl-pkgconfig
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -DBUILD_SHARED_LIBS=ON .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/xz-${XZ_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/xz-${XZ_VERSION}/add-pc-install.patch
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/xz
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/licenses/xz
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING.GPLv2        ${PERL_INST_DIR}/c/licenses/xz
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING.GPLv3        ${PERL_INST_DIR}/c/licenses/xz
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING.LGPLv2.1     ${PERL_INST_DIR}/c/licenses/xz
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# No test target
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project zstd
# ===========================================================
ExternalProject_Add(zstd
                    DEPENDS                perl-pkgconfig
					#
					# There IS a test target but it far too long... in addition tests's CMakeLists.txt is wrong
					#
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -DZSTD_LEGACY_SUPPORT=ON -DBUILD_TESTING=OFF -DZSTD_PROGRAMS_LINK_SHARED=ON -DZSTD_BUILD_TESTS=ON -DZSTD_BUILD_SHARED=ON -DZSTD_BUILD_STATIC=ON .
					SOURCE_SUBDIR          build/cmake
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/zstd-${ZSTD_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/zstd-${ZSTD_VERSION}/tests-CMakeLists.patch
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/zstd
					COMMAND                ${CMAKE_COMMAND} -E copy ../../COPYING        ${PERL_INST_DIR}/c/licenses/zstd
					COMMAND                ${CMAKE_COMMAND} -E copy ../../LICENSE        ${PERL_INST_DIR}/c/licenses/zstd
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# There IS a test target but it far too long
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project libwebp
# ===========================================================
ExternalProject_Add(libwebp
                    DEPENDS                perl-pkgconfig zlib libpng libjpeg-turbo giflib sdl12-compat
					#
					# Take care: libwebp export nothing by default, so producing a DLL will generated no LIB
					#
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libwebp-${LIBWEBP_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/libwebp-${LIBWEBP_VERSION}/change-cmake-install-path.patch
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -DBUILD_SHARED_LIBS=OFF .
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/libwebp
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/licenses/libwebp
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# No test target ?
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project gdiplus
# ===========================================================
ExternalProject_Add(gdiplus
                    DEPENDS                perl-pkgconfig
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/gdiplus-${GDIPLUS_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/gdiplus/CMakeLists.txt CMakeLists.txt
					#
					# No test target ?
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project freeglut
# ===========================================================
ExternalProject_Add(freeglut
                    DEPENDS                perl-pkgconfig
					#
					# Take care: libwebp export nothing by default, so producing a DLL will generated no LIB
					#
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/freeglut-${FREEGLUT_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/freeglut-${FREEGLUT_VERSION}/fix-pc.patch
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/freeglut
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/licenses/freeglut
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# No test target ?
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project tiff
# ===========================================================
ExternalProject_Add(tiff
					DEPENDS                perl-pkgconfig zlib libjpeg-turbo libdeflate jbigkit lerc xz zstd libwebp freeglut
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -Dlzma=ON .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/tiff-${TIFF_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/add_v4.4.0.html_to_docfiles.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/CVE-2022-2056_CVE-2022-2057_CVE-2022-2058.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/CVE-2022-34526.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/CVE-2022-3597_CVE-2022-3626_CVE-2022-3627.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/CVE-2022-3570.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/CVE-2022-3599.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/CVE-2022-3598.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/libtiff.def.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/tiff-${TIFF_VERSION}/use-freeglut-instead-of-glut.patch
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/tiff
					COMMAND                ${CMAKE_COMMAND} -E copy COPYRIGHT            ${PERL_INST_DIR}/c/licenses/tiff
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# Test suite will require access to zlib
					#
					# TEST_COMMAND           ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} test
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project libXpm
# ===========================================================
ExternalProject_Add(libXpm
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libXpm-${LIBXPM_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/libXpm/CMakeLists.txt CMakeLists.txt
					COMMAND                ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/libXpm/Xpm.def Xpm.def
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/libXpm-${LIBXPM_VERSION}/enforce-FOR_MSW-ifdef-_MSC_VER-and-remove-x11-dependency-in-pc.patch
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/libXpm
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/licenses/libXpm
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# No test suite
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

add_custom_target(perl-prima
				  DEPENDS                  perl-pkgconfig fribidi thai giflib libheif libjpeg-turbo libpng tiff gdiplus libXpm
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl Prima
				  )

# ===========================================================
# External project libxml2
# ===========================================================
ExternalProject_Add(libxml2
                    DEPENDS                perl-pkgconfig
					#
					# Take care: libwebp export nothing by default, so producing a DLL will generated no LIB
					#
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libxml2-${LIBXML2_VERSION}.tar.gz
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -DLIBXML2_WITH_PYTHON=OFF .
					#
					# Really, why this extra file is needed in their CMakeLists.txt ? In addition it is not there
					#
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy include/libxml/xmlversion.h.in include/libxml/xmlwin32version.h.in
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					#
					# libxml2 install an xml2-config and xml2Conf.sh that are a shell script! This will perturb very much Alien::Libxml2
					#
					COMMAND                ${CMAKE_COMMAND} -E echo                      "Removing ${PERL_INST_DIR}/c/bin/xml2-config"
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl -e "unlink shift" "${PERL_INST_DIR}/c/bin/xml2-config"
					COMMAND                ${CMAKE_COMMAND} -E echo                      "Removing ${PERL_INST_DIR}/c/lib/xml2Conf.sh"
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl -e "unlink shift" "${PERL_INST_DIR}/c/lib/xml2Conf.sh"
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/libxml2
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/licenses/libxml2
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

add_custom_target(perl-xml-libxml
				  DEPENDS                  perl-pkgconfig libxml2
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl SHLOMIF/XML-LibXML-${PERL_XML_LIBXML_VERSION}.tar.gz
				  )

# ===========================================================
# External project winflexbison - Take care original CMakeLists.txt of this project work only with the Release build type
# ===========================================================
ExternalProject_Add(winflexbison
                    DEPENDS                perl-pkgconfig
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/winflexbison-${WINFLEXBISON_VERSION}.tar.gz
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					#
					# libxml2 install an xml2-config and xml2Conf.sh that are a shell script! This will perturb very much Alien::Libxml2
					#
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/winflexbison
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/licenses/winflexbison
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project libpcap (note openssl dependency is implicitly resolved with perl-pkgconfig, but well)
# ===========================================================
ExternalProject_Add(libpcap
                    DEPENDS                perl-pkgconfig openssl winflexbison
					#
					# Take care: libwebp export nothing by default, so producing a DLL will generated no LIB
					#
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libpcap-${LIBPCAP_VERSION}.tar.gz
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -DDISABLE_NETMAP=ON -DDISABLE_BLUETOOTH=ON -DDISABLE_DBUS=ON -DDISABLE_RDMA=ON -DDISABLE_DAG=ON -DDISABLE_SEPTEL=ON -DDISABLE_SNF=ON -DDISABLE_TC=ON -DDISABLE_PACKET=ON -DENABLE_REMOTE=OFF -DUSE_STATIC_RT=OFF .
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/libpcap-${LIBPCAP_VERSION}/add-disable-packet-option.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/libpcap-${LIBPCAP_VERSION}/install-pc-on-msvc.patch
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					#
					# libxml2 install an xml2-config and xml2Conf.sh that are a shell script! This will perturb very much Alien::Libxml2
					#
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/licenses/libpcap
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE              ${PERL_INST_DIR}/c/licenses/libpcap
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project bzip2
# ===========================================================
ExternalProject_Add(bzip2
                    DEPENDS                perl-pkgconfig
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/bzip2-${BZIP2_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/bzip2-master/bz2-install.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/bzip2-master/bz2-library-name-in-def.patch
					#
					# Painful but bzip2 requires... python to run tests or install docs
					#
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -DENABLE_TESTS=OFF -DENABLE_DOCS=OFF .
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory                 ${PERL_INST_DIR}/c/licenses/bzip2
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING                   ${PERL_INST_DIR}/c/licenses/bzip2
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project brotli
# ===========================================================
ExternalProject_Add(brotli
                    DEPENDS                perl-pkgconfig
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/brotli-${BROTLI_VERSION}.tar.gz
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory                 ${PERL_INST_DIR}/c/licenses/brotli
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE                   ${PERL_INST_DIR}/c/licenses/brotli
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# Tests requires Wine event on Windows -;
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project freetype
# ===========================================================
ExternalProject_Add(freetype
                    DEPENDS                perl-pkgconfig zlib libpng bzip2 brotli
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/freetype-${FREETYPE_VERSION}.tar.gz
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -DBUILD_SHARED_LIBS=ON ../freetype
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory                 ${PERL_INST_DIR}/c/licenses/freetype
					COMMAND                ${CMAKE_COMMAND} -E copy ../freetype/LICENSE.TXT   ${PERL_INST_DIR}/c/licenses/freetype
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# Not test ?
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					#
					# It explicitly check for build in source -;
					#
					BUILD_IN_SOURCE        FALSE)

# ===========================================================
# External project harfbuzz
# ===========================================================
ExternalProject_Add(harfbuzz
                    DEPENDS                perl-pkgconfig freetype
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/harfbuzz-${HARFBUZZ_VERSION}.tar.gz
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -DHB_HAVE_FREETYPE=ON -DBUILD_SHARED_LIBS=ON -G "${CMAKE_GENERATOR}" ../harfbuzz
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory                 ${PERL_INST_DIR}/c/licenses/harfbuzz
					COMMAND                ${CMAKE_COMMAND} -E copy ../harfbuzz/COPYING       ${PERL_INST_DIR}/c/licenses/harfbuzz
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# It needs python for the tests
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					#
					# It explicitly check for build in source -;
					#
					BUILD_IN_SOURCE        FALSE)

# ===========================================================
# External project highway
# ===========================================================
ExternalProject_Add(highway
                    DEPENDS                perl-pkgconfig
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/highway-${HIGHWAY_VERSION}.tar.gz
					#
					# It required googletest to run the tests
					#
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -DBUILD_SHARED_LIBS=ON -DHWY_ENABLE_TESTS=OFF -G "${CMAKE_GENERATOR}" .
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory                 ${PERL_INST_DIR}/c/licenses/highway
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE                   ${PERL_INST_DIR}/c/licenses/highway
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					#
					# It explicitly check for build in source -;
					#
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project lcms2
# ===========================================================
ExternalProject_Add(lcms2
                    DEPENDS                perl-pkgconfig
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/lcms2-${LCMS2_VERSION}.tar.gz
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/lcms2/CMakeLists.txt CMakeLists.txt
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory                 ${PERL_INST_DIR}/c/licenses/lcms2
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING                   ${PERL_INST_DIR}/c/licenses/lcms2
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project imath
# ===========================================================
ExternalProject_Add(imath
                    DEPENDS                perl-pkgconfig
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/imath-${IMATH_VERSION}.tar.gz
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" -DIMATH_INSTALL_PKG_CONFIG=ON .
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory                 ${PERL_INST_DIR}/c/licenses/imath
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE.md                ${PERL_INST_DIR}/c/licenses/imath
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# https://github.com/AcademySoftwareFoundation/Imath/issues/283
					#
					TEST_EXCLUDE_FROM_MAIN FALSE
					TEST_BEFORE_INSTALL    TRUE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project openexr
# ===========================================================
ExternalProject_Add(openexr
                    DEPENDS                perl-pkgconfig imath
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/openexr-${OPENEXR_VERSION}.tar.gz
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -DOPENEXR_INSTALL_PKG_CONFIG=ON -G "${CMAKE_GENERATOR}" .
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory                 ${PERL_INST_DIR}/c/licenses/openexr
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE.md                ${PERL_INST_DIR}/c/licenses/openexr
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# A lot of tests fail, github issues seems to say "do not worry". Executing some tests by hand work when they fail in CTest. I suspect a path issue for me specific case.
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project libavif
# ===========================================================
ExternalProject_Add(libavif
                    DEPENDS                perl-pkgconfig aom
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libavif-${LIBAVIF_VERSION}.tar.gz
					#
					# Again tests that depend on google test
					#
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -DAVIF_CODEC_AOM=ON -DAVIF_CODEC_AOM_DECODE=ON -DAVIF_CODEC_AOM_ENCODE=ON -DAVIF_ENABLE_GTEST=OFF -DAVIF_ENABLE_WERROR=OFF -G "${CMAKE_GENERATOR}" .
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory                 ${PERL_INST_DIR}/c/licenses/libavif
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE                   ${PERL_INST_DIR}/c/licenses/libavif
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# A lot of tests fail, github issues seems to say "do not worry". Executing some tests by hand work when they fail in CTest. I suspect a path issue for me specific case.
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project libjxl
# ===========================================================
ExternalProject_Add(libjxl
                    DEPENDS                perl-pkgconfig brotli zlib libpng highway lcms2 openexr giflib libjpeg-turbo libwebp libavif
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/libjxl-${LIBJXL_VERSION}.tar.gz
					#
					# It required GTest to run the tests
					#
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -DJPEGXL_ENABLE_SKCMS=OFF -DBUILD_TESTING=OFF -DJPEGXL_ENABLE_SJPEG=OFF -DJPEGXL_ENABLE_JNI=OFF -G "${CMAKE_GENERATOR}" .
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory                 ${PERL_INST_DIR}/c/licenses/libjxl
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE                   ${PERL_INST_DIR}/c/licenses/libjxl
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE.apngdis           ${PERL_INST_DIR}/c/licenses/libjxl
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE.jpeg-xl           ${PERL_INST_DIR}/c/licenses/libjxl
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					# Not test ?
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project GraphicsMagick
# ===========================================================
ExternalProject_Add(GraphicsMagick
                    DEPENDS                perl-pkgconfig zlib bzip2 jbigkit libjpeg-turbo libpng tiff libjxl lcms2 xz libxml2 freetype
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/3rdparty/GraphicsMagick-${GRAPHICSMAGICK_VERSION}.tar.gz
				    COMMAND                ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/GraphicsMagick/CMakeLists.txt GraphicsMagick/CMakeLists.txt
					COMMAND                ${CMAKE_COMMAND} -E make_directory            GraphicsMagick/cmake
					COMMAND                ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/GraphicsMagick/cmake/FindJBIG.cmake GraphicsMagick/cmake/FindJBIG.cmake
					COMMAND                ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/3rdparty/files/GraphicsMagick/cmake/FindJBIG85.cmake GraphicsMagick/cmake/FindJBIG85.cmake
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -G "${CMAKE_GENERATOR}" .
					PATCH_COMMAND          ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/GraphicsMagick-${GRAPHICSMAGICK_VERSION}/coders-jxl.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/GraphicsMagick-${GRAPHICSMAGICK_VERSION}/coders-msl.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/GraphicsMagick-${GRAPHICSMAGICK_VERSION}/coders-svg.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/GraphicsMagick-${GRAPHICSMAGICK_VERSION}/coders-url.patch
					COMMAND                ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/3rdparty/patches/GraphicsMagick-${GRAPHICSMAGICK_VERSION}/magick-types-for-ssize_t.patch
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory                 ${PERL_INST_DIR}/c/licenses/GraphicsMagick
					COMMAND                ${CMAKE_COMMAND} -E copy Copyright.txt             ${PERL_INST_DIR}/c/licenses/GraphicsMagick
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/post-install.pl
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL    FALSE
					BUILD_IN_SOURCE        TRUE)

# ====================================================================================================================================
# We consider that perl is ready when modules that require special post-install rules or are dependant on external projets are done:
# Net::SSleay
# Win32::GUI
# XML::Parser
# XML::LibXML
# Prima
# ====================================================================================================================================
add_custom_target(perl               DEPENDS perl-io-socket-ssl perl-win32-gui perl-xml-parser perl-xml-libxml perl-prima)

# ====================================================================================================================================
# From now on, we just create rules for all the extra packages
# ====================================================================================================================================
SET (PACKAGES
	Image::Size
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
	# Win32::pwent            Works only on non-DC, contains a "die" etc...
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
	# Win32::DirSize         # Too badly package, c.f. https://rt.cpan.org/Ticket/Display.html?id=93796
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
	Win32::GUIRobot
	Win32::Hardlink
	Win32::IPConfig
	# Win32::IPHelper       # Useless and quite bad
	# Win32::Internet       # Too old and useless given modern perl
	Win32::LongPath
	Win32::NetAdmin         # t/netadmin.t patched in case you run as admin
	# Win32::PingICMP       # Not necessary IMHO very very old package
	# Win32::PrintBox       # Depend on Win32::Console::ANSI that is well...
	Win32::Registry         # Claimed deprecated but still seems ok, tests as administrator ok for me
	Win32::Setupsup
	# Win32::ShellExt       # Even perl Makefile.PL complains...
	Win32::Shortcut         # Note: no test ;)
	Win32::ShutDown         # Compiles ok, not really tested event if there is a test suite that intentionnaly will not shutdown of course
	# Win32::SoundRec       # Depends on Win32::API::Prototype (...) + RT reports are not really enthusiastic
	Win32::Symlinks
	Win32::ToolHelp
	# Win32::UrlCache       # Umaintained very old package that do not install
	Win32::VBScript
	Win32::ADRecurse
	# Win32::CaptureIE      # Obsolete - ImageMagick dependency
	Win32::Clipboard
	Win32::CryptData
	Win32::DriveInfo
	Win32::ErrorMode
	Win32::Filenames
	# Win32::NetPacket      # Catastrophic Makefile.PL - I just give up
	# Win32::RemoteTOD      # It installs what ?
	# Win32::Resources      # Test fail
	# Win32::Shortkeys      # Does not compile (WinAble.h to be replaced by WinUser.h ?)
	# Win32::SqlServer		# Note: need https://learn.microsoft.com/fr-fr/sql/connect/oledb/applications/installing-oledb-driver-for-sql-server
	Win32::Wallpaper
	Win32::FileNotify
	Win32::FindWindow
	Win32::ParseWords
	Win32::PowerPoint
	Win32::RunAsAdmin
)

foreach(package ${PACKAGES})
  # Transform package to a rule like perl-xxx
  SET(rule "perl-${package}")
  string(TOLOWER ${rule} rule)
  string(REPLACE "::" "-" rule ${rule})
  add_custom_target(${rule} ALL DEPENDS perl COMMAND ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl ${PROJECT_SOURCE_DIR}/installer.pl ${package})
endforeach()

#
# Specific Packages failures...
#
add_dependencies(perl-win32-wallpaper perl-image-size)
