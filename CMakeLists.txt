#
# Example: cmake -G "NMake Makefiles" .
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

set (PERL_TEST_DEFAULT                     ON)
set (OPENSSL_VERSION_DEFAULT               3.0.5)
set (OPENSSL_TEST_DEFAULT                  ON)
set (NASM_VERSION_DEFAULT                  2.15.05)
set (PERL_NET_SSLEAY_VERSION_DEFAULT       1.93_01)
set (PERL_WIN32_GUI_VERSION_DEFAULT        1.14)
set (LIBTIFF_VERSION_DEFAULT               4.4.0)
set (ZLIB_VERSION_DEFAULT                  1.2.13)
set (LIBDEFLATE_VERSION_DEFAULT            1.14)
set (LIBJPEG_TURBO_VERSION_DEFAULT         2.1.4)
set (JBIGKIT_VERSION_DEFAULT               2.1)
set (LERC_VERSION_DEFAULT                  4.0.0)
set (XZ_VERSION_DEFAULT                    5.2.7)
set (ZSTD_VERSION_DEFAULT                  1.5.2)
set (WEBP_VERSION_DEFAULT                  1.2.4)
set (LIBPNG_VERSION_DEFAULT                1.6.38)
set (GIFLIB_VERSION_DEFAULT                5.2.1)
set (SDL2_VERSION_DEFAULT                  2.24.1)

set (PERL_INST_DRV                 ${PERL_INST_DRV_DEFAULT}                 CACHE STRING "Perl installation drive")
set (PERL_VERSION                  ${PERL_VERSION_DEFAULT}                  CACHE STRING "Perl version")
set (PERL_TEST                     ${PERL_TEST_DEFAULT}                     CACHE STRING "Perl test")
set (OPENSSL_VERSION               ${OPENSSL_VERSION_DEFAULT}               CACHE STRING "Openssl version")
set (OPENSSL_TEST                  ${OPENSSL_TEST_DEFAULT}                  CACHE STRING "Openssl test")
set (NASM_VERSION                  ${NASM_VERSION_DEFAULT}                  CACHE STRING "Nasm version")
set (PERL_NET_SSLEAY_VERSION       ${PERL_NET_SSLEAY_VERSION_DEFAULT}       CACHE STRING "Specific Net::SSLeay version")
set (PERL_WIN32_GUI_VERSION        ${PERL_WIN32_GUI_VERSION_DEFAULT}        CACHE STRING "Specific Win32::GUI version")
set (LIBTIFF_VERSION               ${LIBTIFF_VERSION_DEFAULT}               CACHE STRING "Libtiff version")
set (ZLIB_VERSION                  ${ZLIB_VERSION_DEFAULT}                  CACHE STRING "Zlib version")
set (LIBDEFLATE_VERSION            ${LIBDEFLATE_VERSION_DEFAULT}            CACHE STRING "Libdeflateversion")
set (LIBJPEG_TURBO_VERSION         ${LIBJPEG_TURBO_VERSION_DEFAULT}         CACHE STRING "Libjpeg-turbo version")
set (JBIGKIT_VERSION               ${JBIGKIT_VERSION_DEFAULT}               CACHE STRING "Jbigkit version")
set (LERC_VERSION                  ${LERC_VERSION_DEFAULT}                  CACHE STRING "Lerc version")
set (XZ_VERSION                    ${XZ_VERSION_DEFAULT}                    CACHE STRING "Xz version")
set (ZSTD_VERSION                  ${ZSTD_VERSION_DEFAULT}                  CACHE STRING "Zstd version")
set (WEBP_VERSION                  ${WEBP_VERSION_DEFAULT}                  CACHE STRING "Webp version")
set (LIBPNG_VERSION                ${LIBPNG_VERSION_DEFAULT}                CACHE STRING "Libpng version")
set (GIFLIB_VERSION                ${GIFLIB_VERSION_DEFAULT}                CACHE STRING "Giflib version")
set (SDL2_VERSION                  ${SDL2_VERSION_DEFAULT}                  CACHE STRING "Sdl2 version")

set_property (CACHE PERL_INST_DRV                 PROPERTY STRINGS ${drives} )
set_property (CACHE PERL_VERSION                  PROPERTY STRINGS ${PERL_VERSIONS})
set_property (CACHE PERL_TEST                     PROPERTY STRINGS ON OFF)
set_property (CACHE OPENSSL_VERSION               PROPERTY STRINGS ${OPENSSL_VERSION_DEFAULT})
set_property (CACHE OPENSSL_TEST                  PROPERTY STRINGS ON OFF)
set_property (CACHE NASM_VERSION                  PROPERTY STRINGS ${NASM_VERSION_DEFAULT})
set_property (CACHE PERL_NET_SSLEAY_VERSION       PROPERTY STRINGS ${PERL_NET_SSLEAY_VERSION_DEFAULT})
set_property (CACHE PERL_WIN32_GUI_VERSION        PROPERTY STRINGS ${PERL_WIN32_GUI_VERSION_DEFAULT})
set_property (CACHE LIBTIFF_VERSION               PROPERTY STRINGS ${LIBTIFF_VERSION_DEFAULT})
set_property (CACHE ZLIB_VERSION                  PROPERTY STRINGS ${ZLIB_VERSION_DEFAULT})
set_property (CACHE LIBDEFLATE_VERSION            PROPERTY STRINGS ${LIBDEFLATE_VERSION_DEFAULT})
set_property (CACHE LIBJPEG_TURBO_VERSION         PROPERTY STRINGS ${LIBJPEG_TURBO_VERSION_DEFAULT})
set_property (CACHE JBIGKIT_VERSION               PROPERTY STRINGS ${JBIGKIT_VERSION_DEFAULT})
set_property (CACHE LERC_VERSION                  PROPERTY STRINGS ${LERC_VERSION_DEFAULT})
set_property (CACHE XZ_VERSION                    PROPERTY STRINGS ${XZ_VERSION_DEFAULT})
set_property (CACHE ZSTD_VERSION                  PROPERTY STRINGS ${ZSTD_VERSION_DEFAULT})
set_property (CACHE WEBP_VERSION                  PROPERTY STRINGS ${WEBP_VERSION_DEFAULT})
set_property (CACHE LIBPNG_VERSION                PROPERTY STRINGS ${LIBPNG_VERSION_DEFAULT})
set_property (CACHE GIFLIB_VERSION                PROPERTY STRINGS ${GIFLIB_VERSION_DEFAULT})

message (STATUS "===================================")
message (STATUS "Version of Perl                   : ${PERL_VERSION}")
message (STATUS "Test of Perl                      : ${PERL_TEST}")
message (STATUS "Version of Openssl                : ${OPENSSL_VERSION}")
message (STATUS "Test of Openssl                   : ${OPENSSL_TEST}")
message (STATUS "Version of Nasm                   : ${NASM_VERSION}")
message (STATUS "Version of Net::SSLeay            : ${PERL_NET_SSLEAY_VERSION}")
message (STATUS "Version of Win32::GUI             : ${PERL_WIN32_GUI_VERSION}")
message (STATUS "Version of Libtiff                : ${LIBTIFF_VERSION}")
message (STATUS "Version of Zlib                   : ${ZLIB_VERSION}")
message (STATUS "Version of Libdeflfate            : ${LIBDEFLATE_VERSION}")
message (STATUS "Version of Libjpeg-turbo          : ${LIBJPEG_TURBO_VERSION}")
message (STATUS "Version of Jbigkit                : ${JBIGKIT_VERSION}")
message (STATUS "Version of Lerc                   : ${LERC_VERSION}")
message (STATUS "Version of Xz                     : ${XZ_VERSION}")
message (STATUS "Version of Zstd                   : ${ZSTD_VERSION}")
message (STATUS "Version of Webp                   : ${WEBP_VERSION}")
message (STATUS "Version of Libpng                 : ${LIBPNG_VERSION}")
message (STATUS "Version of Giflib                 : ${GIFLIB_VERSION}")
message (STATUS "Version of Sdl2                   : ${SDL2_VERSION}")
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

set (PERL_C_INST_DIR "${PERL_INST_DIR}/c")
cmake_path(CONVERT "${PERL_C_INST_DIR}" TO_NATIVE_PATH_LIST PERL_C_INST_DIR_DOS)

set (CPAN_PATCHES_DIR "${CMAKE_CURRENT_BINARY_DIR}/.cpan/patches")
cmake_path(CONVERT "${CPAN_PATCHES_DIR}" TO_NATIVE_PATH_LIST CPAN_PATCHES_DIR_DOS)

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
SET WIN32_GUI_FREEIMAGE_EXTLIB=${PERL_C_INST_DIR_DOS}\\lib\\freeimage.lib
SET WIN32_GUI_FREEIMAGE_INCDIR=${PERL_C_INST_DIR_DOS}\\include

REM
REM For runtime of the above packages, we absolutely want perl to be before
REM
SET PATH=${PERL_INST_DIR_DOS}\\bin;${PERL_C_INST_DIR_DOS}\\bin;%PATH%

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
# External project perl-core
# ===========================================================
ExternalProject_Add(perl-core
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					URL                    https://www.cpan.org/src/5.0/perl-${PERL_VERSION}.tar.gz
					SOURCE_SUBDIR          win32
					PATCH_COMMAND          ${CMAKE_COMMAND} -E env ${PERLPATCH_BAT_DOS} ${REPLACE_VBS_DOS} ${PERL_CCTYPE} ${PERL_WIN64} ${PERL_INSTSUBDIR} ${PERL_INST_DRV}
					CONFIGURE_COMMAND      ${CMAKE_COMMAND} -E echo "Configuration step skipped: using win32\\Makefile"
					TEST_EXCLUDE_FROM_MAIN $<IF:${PERL_TEST},OFF,ON>
					TEST_BEFORE_INSTALL    $<IF:${PERL_TEST},ON,OFF>
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project nasm
# ===========================================================
ExternalProject_Add(nasm
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DEPENDS                perl-core
					URL                    https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.gz
					#
					# Mkfiles/msvc.mak bug, c.f. https://forum.nasm.us/index.php?topic=2746.msg12335#msg12335
					#
					PATCH_COMMAND          ${Patch_EXECUTABLE} Mkfiles/msvc.mak ${PROJECT_SOURCE_DIR}/nasm_msvc_mak.diff
					#
					# It needs Font::TTF Sort::Versions perl modules as per the doc
					#
					CONFIGURE_COMMAND      ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cpan Font::TTF Sort::Versions
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

# ===========================================================
# External project openssl
# ===========================================================
ExternalProject_Add(openssl
					DEPENDS                nasm
					URL                    https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
					CONFIGURE_COMMAND      ${CMAKE_COMMAND} -E env LDFLAGS=${OPENSSL_LDFLAGS} ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat perl Configure --prefix=${PERL_C_INST_DIR_DOS} --openssldir=${PERL_C_INST_DIR_DOS}\\SSL enable-fips enable-weak-ssl-ciphers ${OPENSSL_VC}
					BUILD_COMMAND          ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM}
					INSTALL_COMMAND        ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/license/openssl
					COMMAND                ${CMAKE_COMMAND} -E copy LICENSE.txt        ${PERL_INST_DIR}/c/license/openssl
					#
					# On Windows openssl test suite is working ok only in Win32::Process is installed
					#
					TEST_COMMAND           ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cpan Win32::Process
					COMMAND                ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat ${CMAKE_MAKE_PROGRAM} test
					TEST_EXCLUDE_FROM_MAIN $<IF:${OPENSSL_TEST},OFF,ON>
					TEST_BEFORE_INSTALL    $<IF:${OPENSSL_TEST},ON,OFF>
					BUILD_IN_SOURCE        TRUE)

# ===========================================================
# External project zlib
# ===========================================================
ExternalProject_Add(zlib
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					URL                    https://github.com/madler/zlib/releases/download/v${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz
					)

# ===========================================================
# External project libdeflate
# ===========================================================
ExternalProject_Add(libdeflate
					URL                    https://github.com/ebiggers/libdeflate/archive/refs/tags/v${LIBDEFLATE_VERSION}.tar.gz
					CONFIGURE_COMMAND      ""
					BUILD_COMMAND          ${CMAKE_MAKE_PROGRAM} -f Makefile.msc
					INSTALL_COMMAND        ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E copy libdeflate.dll       ${PERL_INST_DIR}/c/bin
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/license/libdeflate
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/license/libdeflate
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/include
					COMMAND                ${CMAKE_COMMAND} -E copy libdeflate.h         ${PERL_INST_DIR}/c/include
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/lib
					COMMAND                ${CMAKE_COMMAND} -E copy libdeflate.lib       ${PERL_INST_DIR}/c/lib
					COMMAND                ${CMAKE_COMMAND} -E copy libdeflatestatic.lib ${PERL_INST_DIR}/c/lib
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE        TRUE
					)

# ===========================================================
# External project libjpeg-turbo
# ===========================================================
ExternalProject_Add(libjpeg-turbo
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -DOLD-JPEG=ON -DCMAKE_ASM_NASM_COMPILER=${PERL_C_INST_DIR}/bin/nasm.exe
					DEPENDS                nasm
					URL                    https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/${LIBJPEG_TURBO_VERSION}.tar.gz
					# Note that it is voluntarily that CMAKE_ASM_NASM_COMPILER uses UNIX style syntax, otherwise enable_language will not like it
					)

# ===========================================================
# External project jbigkit
# ===========================================================
ExternalProject_Add(jbigkit
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					URL                    http://www.cl.cam.ac.uk/~mgk25/download/jbigkit-${JBIGKIT_VERSION}.tar.gz
					PATCH_COMMAND          ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/jbigkit-CMakeLists.txt CMakeLists.txt
					)

# ===========================================================
# External project lerc
# ===========================================================
ExternalProject_Add(lerc
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					URL                    https://github.com/Esri/lerc/archive/refs/tags/v${LERC_VERSION}.tar.gz
					)

# ===========================================================
# External project Xz
# ===========================================================
ExternalProject_Add(xz
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -DBUILD_SHARED_LIBS=ON
					URL                    https://tukaani.org/xz/xz-${XZ_VERSION}.tar.gz
					)

# ===========================================================
# External project Zstd
# ===========================================================
ExternalProject_Add(zstd
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					URL                    https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz
					SOURCE_SUBDIR          build/cmake
					)

# ===========================================================
# External project Libpng
# ===========================================================
ExternalProject_Add(libpng
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DEPENDS                libjpeg-turbo zlib
					URL                    https://github.com/glennrp/libpng/archive/refs/tags/v${LIBPNG_VERSION}.tar.gz
					)

# ===========================================================
# External project Giflib
# ===========================================================
ExternalProject_Add(giflib
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					URL                    https://github.com/jddurand/perlbuildwindows/raw/main/giflib-${GIFLIB_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} < ${PROJECT_SOURCE_DIR}/giflib-5.2.1.diff
					INSTALL_COMMAND        ${CMAKE_MAKE_PROGRAM} install
					COMMAND                ${CMAKE_COMMAND} -E make_directory            ${PERL_INST_DIR}/c/license/giflib
					COMMAND                ${CMAKE_COMMAND} -E copy COPYING              ${PERL_INST_DIR}/c/license/giflib
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE        TRUE
					)

# ===========================================================
# External project Sdl2
# ===========================================================
ExternalProject_Add(sdl2
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					URL                    https://github.com/libsdl-org/SDL/releases/download/release-${SDL2_VERSION}/SDL2-${SDL2_VERSION}.tar.gz
					)

# ===========================================================
# External project Webp
# ===========================================================
ExternalProject_Add(webp
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS} -DWEBP_BUILD_CWEBP=ON -DWEBP_BUILD_DWEBP=ON
					DEPENDS                libjpeg-turbo zlib libpng giflib
					URL                    https://github.com/webmproject/libwebp/archive/refs/tags/v${WEBP_VERSION}.zip
					)

# ===========================================================
# External project libtiff
# ===========================================================
ExternalProject_Add(libtiff
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DEPENDS                zlib libdeflate libjpeg-turbo jbigkit lerc xz zstd webp
					URL                    https://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz
					PATCH_COMMAND          ${Patch_EXECUTABLE} cmake/LZMACodec.cmake ${PROJECT_SOURCE_DIR}/libtiff-4.4.0.diff
					)

# ===========================================================
# External project freeimage
# ===========================================================
ExternalProject_Add(freeimage
                    CMAKE_ARGS             -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH:PATH=${PERL_C_INST_DIR_DOS} -DCMAKE_INSTALL_PREFIX:PATH=${PERL_C_INST_DIR_DOS}
					DOWNLOAD_COMMAND       ${CMAKE_COMMAND} -E tar xf ${PROJECT_SOURCE_DIR}/FreeImage-3.18.0.tar.gz
				    COMMAND                ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/FreeImage_CMakeLists.txt freeimage/CMakeLists.txt
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE        TRUE)

# ====================================================================================================================================
# Net::SSLeay has post-installation of openssl libraries near Net::SSLeay
# ====================================================================================================================================
add_custom_target(perl-net-ssleay
				  DEPENDS                  perl-core openssl
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cpan CHRISN/Net-SSLeay-${PERL_NET_SSLEAY_VERSION}.tar.gz
				  #
				  # Post-install: copy openssl libraries near Net::SSLeay
				  #
				  COMMAND                  ${CMAKE_COMMAND} -E copy ${PERL_INST_DIR}/c/bin/libcrypto-3.dll ${PERL_INST_DIR}/site/lib/auto/Net/SSLeay
				  COMMAND                  ${CMAKE_COMMAND} -E copy ${PERL_INST_DIR}/c/bin/libssl-3.dll ${PERL_INST_DIR}/site/lib/auto/Net/SSLeay
				  )

# ====================================================================================================================================
# Win32::GUI has post-installation of freeimage library near Win32::GUI
# ====================================================================================================================================
add_custom_target(perl-win32-gui
				  DEPENDS                  perl-core freeimage
				  COMMAND                  ${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat cpan KMX/Win32-GUI-${PERL_WIN32_GUI_VERSION}.tar.gz
				  #
				  # Post-install: copy freeimage library near Win32::GUI::DIBitmap
				  #
				  COMMAND                  ${CMAKE_COMMAND} -E copy ${PERL_INST_DIR}/c/bin/freeimage.dll ${PERL_INST_DIR}/site/lib/auto/Win32/GUI/DIBitmap
				  )

# ====================================================================================================================================
# We consider that perl is ready when perl-core and modules that require special additional commands are complete
# ====================================================================================================================================
add_custom_target(perl
				  DEPENDS                  perl-net-ssleay perl-win32-gui
				  )

# ====================================================================================================================================
# Other perl modules
# ====================================================================================================================================
# Every module that needs a patch
add_custom_target(PerlModules
				  ALL
				  #
				  # We want to depend on perl modules that required a custom installation (i.e. a copy of a dlls near the module binary)
				  #
				  DEPENDS                  perl-net-ssleay perl-win32-gui
                  COMMENT                  "Perl modules"
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           IO::Socket
				  #
				  # IO::Socket::SSL is painful, its test suite regularly fails though the module seems ok
				  # IPC::Run - cross fingers, it is a pain to depend on this module that accumulates too many bugs
				  #
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpanm.bat" --notest IO::Socket::SSL IPC::Run
				  #
				  # Most of WIN32:: thingies
				  #
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           Win32::WQL Win32::ADO Win32::API Win32::ASP Win32::CLR Win32::Env Win32::HTA Win32::IPC
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           Win32::Job Win32::File Win32::ODBC Win32::Pipe Win32::SDDL Win32::Sound Win32::Vcpkg Config::Win32
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           Win32::Daemon Win32::FileOp Win32::JobAdd Win32::Locale Win32::PEFile Win32::Uptime
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           Win32::AbsPath Win32::Console Win32::MinXSLT Win32::Printer Win32::Process Win32::Service
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           Win32::Symlink Win32::Tracert Win32::Wingraph Win32::Autoglob Win32::Detached
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           Win32::EventLog Win32::Hardlink Win32::IPConfig Win32::IPHelper Win32::Internet Win32::Registry
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           Win32::Shortcut Win32::ShutDown Win32::Symlinks Win32::VBScript Win32::ADRecurse
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           Win32::Clipboard Win32::CryptData Win32::DriveInfo Win32::EmailSend Win32::ErrorMode
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           Win32::Filenames Win32::FileNotify Win32::Unicode::Shortcut Win32::Unicode::InternetShortcut
				  #
				  # We choose first "big" packages, that install a lot of stuff, though we avoid Acme
				  #
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           DBD::SQLite Dist::Zilla
				  #
				  # Others
				  #
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           MarpaX::ESLIF
				  DEPENDS openssl)

if (FALSE)
# ===========================================================
# Install cpanm assap
# We ask to depend on the perl modules that we patched.
# Namely only Net::SSLeay at this stage.
# ===========================================================

# cpanm strongly suggests CPAN::DistnameInfo
add_custom_target(PerlCPANDistnameInfo
                  COMMENT "Perl module CPAN::DistnameInfo"
				  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" CPAN::DistnameInfo
				  DEPENDS perl)

# HTTP::Tiny is better suited for download
add_custom_target(PerlHTTPTiny
                  COMMENT "Perl module HTTP::Tiny"
				  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" HTTP::Tiny
				  DEPENDS perl)

add_custom_target(PerlAppcpanminus
                  ALL
				  DEPENDS perl-net-ssleay PerlCPANDistnameInfo PerlHTTPTiny
				  COMMENT "Perl module App::cpanminus"
				  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" App::cpanminus)

# ===========================================================
# Install other perl modules
# ===========================================================
set(PERL_MODULES_TXT "${PROJECT_SOURCE_DIR}/perl_modules.txt")
file(STRINGS ${PERL_MODULES_TXT} perl_modules)
foreach(line ${perl_modules})
    string(REGEX REPLACE "[ \t]*#.*" "" line ${line})
    string(REGEX REPLACE "^[ \t]+" "" line ${line})
    string(REGEX REPLACE "[ \t]+" " " line ${line})
    string(REGEX MATCH "^[a-zA-Z0-9_: -]+" perl_module_cpanm_all_arguments ${line})
	string(LENGTH "${perl_module_cpanm_all_arguments}" perl_module_cpanm_all_arguments_length)
	if (perl_module_cpanm_all_arguments_length GREATER 0)
        string(REGEX MATCH "[a-zA-Z0-9_:]+$" perl_module_name ${perl_module_cpanm_all_arguments})
		string(LENGTH "${perl_module_name}" perl_module_name_length)
		if (perl_module_name_length GREATER 0)
			set(perl_module_target ${perl_module_name})
			string(REGEX REPLACE ":" "_" perl_module_target ${perl_module_target})
			string(REGEX MATCHALL "[^ \t]+" perl_module_cpanm_arguments ${perl_module_cpanm_all_arguments})
			message(STATUS "To be executed: cpanm ${perl_module_cpanm_all_arguments}")
			add_custom_target(${perl_module_target}
							  ALL
							  DEPENDS PerlAppcpanminus
							  COMMENT "Perl module ${perl_module_name} using cpanm ${perl_module_cpanm_all_arguments}"
							  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpanm.bat"
							  ${perl_module_cpanm_arguments}
							  )
		endif ()
	endif ()
endforeach()
endif()
