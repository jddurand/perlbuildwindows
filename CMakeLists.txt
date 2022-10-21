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
set (NASM_VERSION_DEFAULT                  2.15.05)
set (PERL_NET_SSLEAY_VERSION_DEFAULT       1.93_01)

set (PERL_INST_DRV                 ${PERL_INST_DRV_DEFAULT}                 CACHE STRING "Perl installation drive")
set (PERL_VERSION                  ${PERL_VERSION_DEFAULT}                  CACHE STRING "Perl version")
set (PERL_TEST                     ${PERL_TEST_DEFAULT}                     CACHE STRING "Perl test")
set (OPENSSL_VERSION               ${OPENSSL_VERSION_DEFAULT}               CACHE STRING "Openssl version")
set (NASM_VERSION                  ${NASM_VERSION_DEFAULT}                  CACHE STRING "Nasm version")
set (PERL_NET_SSLEAY_VERSION       ${PERL_NET_SSLEAY_VERSION_DEFAULT}       CACHE STRING "Perl's Net::SSLeay version (patch is applied)")

set_property (CACHE PERL_INST_DRV                 PROPERTY STRINGS ${drives} )
set_property (CACHE PERL_VERSION                  PROPERTY STRINGS ${PERL_VERSIONS})
set_property (CACHE PERL_TEST                     PROPERTY STRINGS ON OFF)
set_property (CACHE OPENSSL_VERSION               PROPERTY STRINGS ${OPENSSL_VERSION_DEFAULT})
set_property (CACHE NASM_VERSION                  PROPERTY STRINGS ${NASM_VERSION_DEFAULT})
set_property (CACHE PERL_NET_SSLEAY_VERSION       PROPERTY STRINGS ${PERL_NET_SSLEAY_VERSION_DEFAULT})

message (STATUS "===================================")
message (STATUS "Version of Perl                   : ${PERL_VERSION}")
message (STATUS "Test of Perl                      : ${PERL_TEST}")
message (STATUS "Version of Openssl                : ${OPENSSL_VERSION}")
message (STATUS "Version of Nasm                   : ${NASM_VERSION}")
message (STATUS "Version of Perl Net::SSLeay       : ${PERL_NET_SSLEAY_VERSION}")
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
set (PERLPATCH_BAT_DOS "${PROJECT_SOURCE_DIR}/perlpatch.bat")
string (REGEX REPLACE "/" "\\\\" PERLPATCH_BAT_DOS ${PERLPATCH_BAT_DOS})

set (REPLACE_VBS_DOS "${PROJECT_SOURCE_DIR}/replace.vbs")
string (REGEX REPLACE "/" "\\\\" REPLACE_VBS_DOS ${REPLACE_VBS_DOS})

set (CMAKE_COMMAND_DOS "${CMAKE_COMMAND}")
string (REGEX REPLACE "/" "\\\\" CMAKE_COMMAND_DOS ${CMAKE_COMMAND_DOS})

set (CMAKE_CURRENT_BINARY_DIR_DOS "${CMAKE_CURRENT_BINARY_DIR}")
string (REGEX REPLACE "/" "\\\\" CMAKE_CURRENT_BINARY_DIR_DOS ${CMAKE_CURRENT_BINARY_DIR_DOS})

set (PERL_INST_DIR "${PERL_INST_DRV}/${PERL_INSTSUBDIR}")
set (PERL_INST_DIR_DOS "${PERL_INST_DIR}")
string (REGEX REPLACE "/" "\\\\" PERL_INST_DIR_DOS ${PERL_INST_DIR_DOS})

# =======================================================
# Generic bat file to invoke anything related to our perl
# =======================================================
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat"
"@ECHO OFF
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
SET HOME=${CMAKE_CURRENT_BINARY_DIR_DOS}
REM
REM The very first time we initialize .cpan/CPAN/MyConfig and cpan will overwrite it
REM
IF NOT EXIST \"%HOME%\\.cpan\" MKDIR \"%HOME%\\.cpan\"
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
  REM patches_dir can be set only via o conf !?
  REM
  DEL .\\tmpFile
  ECHO o conf patches_dir \"${CMAKE_CURRENT_BINARY_DIR}/.cpan/patches\" > .\\tmpFile
  ECHO o conf commit >> .\\tmpFile
  TYPE .\\tmpFile | cpan
  DEL .\\tmpFile
)
REM
REM
REM For Net::SSLeay...
REM
SET OPENSSL_PREFIX=${PERL_INST_DIR_DOS}\\c
REM
REM For Win32::GUI...
REM
SET WIN32_GUI_USE_FREEIMAGE_DLL=1
SET WIN32_GUI_FREEIMAGE_EXTLIB=${PERL_INST_DIR_DOS}\\c\\lib\\freeimage.lib
SET WIN32_GUI_FREEIMAGE_INCDIR=${PERL_INST_DIR_DOS}\\c\\include
REM
REM For runtime of the above packages
REM
SET PATH=${PERL_INST_DIR_DOS}\\bin;${PERL_INST_DIR_DOS}\\c\\bin;%PATH%
SET HOME=${CMAKE_CURRENT_BINARY_DIR_DOS}
ECHO | %*
")

# ===========================================================
# External project perl-core
# ===========================================================
if (PERL_TEST)
	set (PERL_TEST_BEFORE_INSTALL ON)
	set (PERL_TEST_EXCLUDE_FROM_MAIN OFF)
else ()
	set (PERL_TEST_BEFORE_INSTALL OFF)
	set (PERL_TEST_EXCLUDE_FROM_MAIN ON)
endif ()

ExternalProject_Add(perl-core
					URL "https://www.cpan.org/src/5.0/perl-${PERL_VERSION}.tar.gz"
					SOURCE_SUBDIR win32
					#
					# One might think that putting environment CCTYPE is enough, but no. It fails near the end.
					# So let's follow perl recommandation, that is putting explicitly CCTYPE in the Makefile
					#
					PATCH_COMMAND     ${CMAKE_COMMAND} -E env "${PERLPATCH_BAT_DOS}" "${REPLACE_VBS_DOS}" "${PERL_CCTYPE}" "${PERL_WIN64}" "${PERL_INSTSUBDIR}" "${PERL_INST_DRV}"
					CONFIGURE_COMMAND ${CMAKE_COMMAND} -E echo "Configuration step skipped: using win32\\Makefile"
					#
					# Uncomment if you want to run make test only if explicitly required on the command-line
					#
					# TEST_EXCLUDE_FROM_MAIN ${PERL_TEST_EXCLUDE_FROM_MAIN}
					TEST_EXCLUDE_FROM_MAIN $<IF:${PERL_TEST},OFF,ON>
					# TEST_BEFORE_INSTALL	${PERL_TEST_BEFORE_INSTALL}
					TEST_BEFORE_INSTALL $<IF:${PERL_TEST},ON,OFF>
					BUILD_IN_SOURCE TRUE)

# ===========================================================
# External project nasm
# ===========================================================
ExternalProject_Add(nasm
					DEPENDS perl-core
					URL "https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.gz"
					#
					# C.f. https://forum.nasm.us/index.php?topic=2746.msg12335#msg12335
					#
					#
					# We use Text::Patch to patch Mkfiles/msvc.mak that contain a little error
					#
					PATCH_COMMAND     ${Patch_EXECUTABLE} Mkfiles/msvc.mak "${PROJECT_SOURCE_DIR}/nasm_msvc_mak.diff"
					#
					# It needs Font::TTF Sort::Versions perl modules as per the doc
					#
					CONFIGURE_COMMAND "${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat" cpan Font::TTF Sort::Versions
					BUILD_COMMAND     ${CMAKE_COMMAND} -E rm -f asm/warnings.time
					COMMAND           ${CMAKE_COMMAND} -E touch asm/warnings.time
					COMMAND           "${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat" ${CMAKE_MAKE_PROGRAM} -f Mkfiles/msvc.mak
					INSTALL_COMMAND   ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/bin
					COMMAND           ${CMAKE_COMMAND} -E copy nasm.exe           ${PERL_INST_DIR}/c/bin
					COMMAND           ${CMAKE_COMMAND} -E copy ndisasm.exe        ${PERL_INST_DIR}/c/bin
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/ldrdf.exe    ${PERL_INST_DIR}/c/bin
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdf2bin.exe  ${PERL_INST_DIR}/c/bin
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdf2com.exe  ${PERL_INST_DIR}/c/bin
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdf2ihx.exe  ${PERL_INST_DIR}/c/bin
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdf2ith.exe  ${PERL_INST_DIR}/c/bin
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdf2srec.exe ${PERL_INST_DIR}/c/bin
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdfdump.exe  ${PERL_INST_DIR}/c/bin
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdflib.exe   ${PERL_INST_DIR}/c/bin
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdx.exe      ${PERL_INST_DIR}/c/bin
					COMMAND           ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/license/nasm
					COMMAND           ${CMAKE_COMMAND} -E copy LICENSE            ${PERL_INST_DIR}/c/license/nasm
					COMMAND           ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/man/man1
					COMMAND           ${CMAKE_COMMAND} -E copy nasm.1             ${PERL_INST_DIR}/c/man/man1
					COMMAND           ${CMAKE_COMMAND} -E copy ndisasm.1          ${PERL_INST_DIR}/c/man/man1
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/ldrdf.1      ${PERL_INST_DIR}/c/man/man1
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdf2bin.1    ${PERL_INST_DIR}/c/man/man1
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdf2com.1    ${PERL_INST_DIR}/c/man/man1
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdf2ihx.1    ${PERL_INST_DIR}/c/man/man1
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdf2ith.1    ${PERL_INST_DIR}/c/man/man1
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdf2srec.1   ${PERL_INST_DIR}/c/man/man1
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdfdump.1    ${PERL_INST_DIR}/c/man/man1
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdflib.1     ${PERL_INST_DIR}/c/man/man1
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/rdx.1        ${PERL_INST_DIR}/c/man/man1
					COMMAND           ${CMAKE_COMMAND} -E make_directory          ${PERL_INST_DIR}/c/lib
					COMMAND           ${CMAKE_COMMAND} -E copy libnasm.lib        ${PERL_INST_DIR}/c/lib
					COMMAND           ${CMAKE_COMMAND} -E copy rdoff/librdoff.lib ${PERL_INST_DIR}/c/lib
					#
					# Uncomment if you want to run make test only if explicitly required on the command-line
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE TRUE)

# ===========================================================
# Download and build openssl.
# ===========================================================
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-configure.bat"
"SET PATH=${PERL_INST_DIR_DOS}\\bin;%PATH%
SET PATH=\"${CMAKE_CURRENT_BINARY_DIR}/${NASM_SOURCE_DIR}\";%PATH%
SET LDFLAGS=${OPENSSL_LDFLAGS}
ECHO | perl Configure --prefix=\"${PERL_INST_DIR_DOS}\\c\" --openssldir=\"${PERL_INST_DIR_DOS}\\c\\SSL\" enable-fips enable-weak-ssl-ciphers %1
")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-build.bat"
"SET PATH=${PERL_INST_DIR_DOS}\\bin;%PATH%
SET PATH=\"${CMAKE_CURRENT_BINARY_DIR}/${NASM_SOURCE_DIR}\";%PATH%
ECHO | ${CMAKE_MAKE_PROGRAM}
")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-install.bat"
"SET PATH=${PERL_INST_DIR_DOS}\\bin;%PATH%
SET PATH=\"${CMAKE_CURRENT_BINARY_DIR}/${NASM_SOURCE_DIR}\";%PATH%
ECHO | ${CMAKE_MAKE_PROGRAM} install
IF NOT EXIST \"${PERL_INST_DIR_DOS}\\c\\license\" MKDIR \"${PERL_INST_DIR_DOS}\\c\\license\"
IF NOT EXIST \"${PERL_INST_DIR_DOS}\\c\\license\\openssl\" MKDIR \"${PERL_INST_DIR_DOS}\\c\\license\\openssl\"
COPY /Y \"LICENSE.txt\" \"${PERL_INST_DIR_DOS}\\c\\license\\openssl\"
")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-test.bat"
"SET PATH=${PERL_INST_DIR_DOS}\\bin;%PATH%
SET PATH=\"${CMAKE_CURRENT_BINARY_DIR}/${NASM_SOURCE_DIR}\";%PATH%
ECHO | ${CMAKE_MAKE_PROGRAM} test
")
set(OPENSSL_SOURCE_DIR "openssl-${OPENSSL_VERSION}")
ExternalProject_Add(openssl
					PREFIX              openssl
					DEPENDS             nasm
					URL                 "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
					SOURCE_DIR          ${OPENSSL_SOURCE_DIR}
					CONFIGURE_COMMAND   ${CMAKE_COMMAND} -E env LDFLAGS=${OPENSSL_LDFLAGS} "${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat" perl Configure --prefix=${PERL_INST_DIR_DOS}\\c --openssldir=${PERL_INST_DIR_DOS}\\c\\SSL enable-fips enable-weak-ssl-ciphers ${OPENSSL_VC}
					# CONFIGURE_COMMAND   "${CMAKE_CURRENT_BINARY_DIR}/openssl-configure.bat" "${OPENSSL_VC}"
					BUILD_COMMAND       "${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat" ${CMAKE_MAKE_PROGRAM}
					# BUILD_COMMAND       "${CMAKE_CURRENT_BINARY_DIR}/openssl-build.bat"
					INSTALL_COMMAND       "${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat" ${CMAKE_MAKE_PROGRAM} install
					# INSTALL_COMMAND     "${CMAKE_CURRENT_BINARY_DIR}/openssl-install.bat"
					TEST_COMMAND       "${CMAKE_CURRENT_BINARY_DIR}/command-with-this-perl.bat" ${CMAKE_MAKE_PROGRAM} test
					# TEST_COMMAND        "${CMAKE_CURRENT_BINARY_DIR}/openssl-test.bat"
					#
					# Uncomment if you want to run make test only if explicitly required on the command-line
					# On windows 70-test_comp.t is hanging, despite openssl seems ok. This is a bug in their test suite I strongly guess.
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					# TEST_BEFORE_INSTALL	TRUE
					BUILD_IN_SOURCE     TRUE)

# ===========================================================
# Build freeimage
# ===========================================================
set(FREEIMAGE_PREFIX "freeimage")

set(FREEIMAGE_SOURCE_DIR "${CMAKE_BINARY_DIR}/freeimage-copy")
set (FREEIMAGE_SOURCE_DIR_DOS "${FREEIMAGE_SOURCE_DIR}")
string (REGEX REPLACE "/" "\\\\" FREEIMAGE_SOURCE_DIR_DOS ${FREEIMAGE_SOURCE_DIR_DOS})

set(FREEIMAGE_ORIG_DIR "${PROJECT_SOURCE_DIR}/3rdparty/FreeImage-Adv")
set (FREEIMAGE_ORIG_DIR_DOS "${FREEIMAGE_ORIG_DIR}")
string (REGEX REPLACE "/" "\\\\" FREEIMAGE_ORIG_DIR ${FREEIMAGE_ORIG_DIR})

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/freeimage-install.bat"
"IF NOT EXIST \"${PERL_INST_DIR_DOS}\\c\\license\" MKDIR \"${PERL_INST_DIR_DOS}\\c\\license\"
IF NOT EXIST \"${PERL_INST_DIR_DOS}\\c\\license\\freeimage\" MKDIR \"${PERL_INST_DIR_DOS}\\c\\license\\freeimage\"
COPY /Y \"${FREEIMAGE_ORIG_DIR_DOS}\\license*.txt\" \"${PERL_INST_DIR_DOS}\\c\\license\\freeimage\"
COPY /Y \"*.lib\" \"${PERL_INST_DIR_DOS}\\c\\lib\"
COPY /Y \"*.dll\" \"${PERL_INST_DIR_DOS}\\c\\bin\"
COPY /Y \"*.pdb\" \"${PERL_INST_DIR_DOS}\\c\\bin\"
COPY /Y \"${FREEIMAGE_ORIG_DIR_DOS}\\\\Source\\FreeImage.h\" \"${PERL_INST_DIR_DOS}\\c\\include\"
")

ExternalProject_Add(freeimage
					PREFIX                 ${FREEIMAGE_PREFIX}
					SOURCE_DIR             ${FREEIMAGE_SOURCE_DIR}
					SOURCE_SUBDIR 		   Source
					DOWNLOAD_COMMAND       "${CMAKE_COMMAND}" -E copy_directory "${FREEIMAGE_ORIG_DIR_DOS}" "${FREEIMAGE_SOURCE_DIR_DOS}"
					INSTALL_COMMAND        "${CMAKE_CURRENT_BINARY_DIR}/freeimage-install.bat"
					TEST_EXCLUDE_FROM_MAIN TRUE)

# ====================================================================================================================================
# Net::SSLeay: we require a specific version that matches our patch, and we do post-installation of openssl libraries near Net::SSLeay
# ====================================================================================================================================
ExternalProject_Add(perl-net-ssleay
					DEPENDS             openssl
					URL                 "https://github.com/radiator-software/p5-net-ssleay/archive/refs/tags/${PERL_NET_SSLEAY_VERSION}.tar.gz"
					CONFIGURE_COMMAND   "" # cpan will take of configure
				    BUILD_COMMAND        ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" CHRISN/Net-SSLeay-${PERL_NET_SSLEAY_VERSION}.tar.gz
					#
					# Post-install: copy openssl libraries near Net::SSLeay
					#
					COMMAND             COPY /Y "${PERL_INST_DIR_DOS}\\c\\bin\\libcrypto-3*" "${PERL_INST_DIR_DOS}\\site\\lib\\auto\\Net\\SSLeay"
					COMMAND             COPY /Y "${PERL_INST_DIR_DOS}\\c\\bin\\libssl-3*" "${PERL_INST_DIR_DOS}\\site\\lib\\auto\\Net\\SSLeay"
					INSTALL_COMMAND     "" # cpan will take of configure
					TEST_EXCLUDE_FROM_MAIN TRUE # cpan will take care of test
					BUILD_IN_SOURCE TRUE)

# Every module that needs a patch
add_custom_target(PerlModules
				  ALL
                  COMMENT "Perl modules"
				  COMMAND ${CMAKE_COMMAND} -E env "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"           Win32::GUI
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
