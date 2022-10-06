#
# Example: cmake -G "NMake Makefiles" .
#
# List of essential files:
#
# CMakeLists.txt
# nasm_msvc_mak.diff
# patch.pl
# perlpatch.bat
# replace.vbs
# SSLeay.xs.diff
#
project(perlbuildwindows LANGUAGES C CXX)
#
# We require version 3.14 to have:
# - SOURCE_SUBDIR working with BUILD_IN_SOURCE
# - CMP0077
#
cmake_minimum_required(VERSION 3.14)

set (PERL_VERSION_DEFAULT            5.36.0)
set (PERL_TEST                       FALSE)
set (OPENSSL_VERSION_DEFAULT         3.0.5)
set (NASM_VERSION_DEFAULT            2.15.05)
set (PERL_NET_SSLEAY_VERSION_DEFAULT 1.93_01)

set (PERL_VERSION            ${PERL_VERSION_DEFAULT}            CACHE STRING "Perl version")
set (PERL_TEST               OFF                                CACHE STRING "Perl test")
set (OPENSSL_VERSION         ${OPENSSL_VERSION_DEFAULT}         CACHE STRING "Openssl version")
set (NASM_VERSION            ${NASM_VERSION_DEFAULT}            CACHE STRING "Nasm version")
set (PERL_NET_SSLEAY_VERSION ${PERL_NET_SSLEAY_VERSION_DEFAULT} CACHE STRING "Perl's Net::SSLeay version")

set_property (CACHE PERL_VERSION PROPERTY STRINGS            ${PERL_VERSION_DEFAULT} ON OFF)
set_property (CACHE PERL_TEST PROPERTY STRINGS               ON OFF)
set_property (CACHE OPENSSL_VERSION PROPERTY STRINGS         ${OPENSSL_VERSION_DEFAULT} ON OFF)
set_property (CACHE NASM_VERSION PROPERTY STRINGS            ${NASM_VERSION_DEFAULT} ON OFF)
set_property (CACHE PERL_NET_SSLEAY_VERSION PROPERTY STRINGS ${PERL_NET_SSLEAY_VERSION_DEFAULT} ON OFF)

message (STATUS "Perl version             : ${PERL_VERSION}")
message (STATUS "Openssl version          : ${OPENSSL_VERSION}")
message (STATUS "Nasm version             : ${NASM_VERSION}")
message (STATUS "Perl Net::SSLeay version : ${PERL_NET_SSLEAY_VERSION}")
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
  set (PERL_WIN64 "#WIN64")
  set (OPENSSL_VC "VC-WIN64A")
  set (OPENSSL_LDFLAGS "/debug")
else ()
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

set (PERL_SOURCE_DIR_DOS "${CMAKE_CURRENT_BINARY_DIR}/perl-${PERL_VERSION}")
string (REGEX REPLACE "/" "\\\\" PERL_SOURCE_DIR_DOS ${PERL_SOURCE_DIR_DOS})

set (CMAKE_MAKE_PROGRAM_DOS "${CMAKE_MAKE_PROGRAM}")
string (REGEX REPLACE "/" "\\\\" CMAKE_MAKE_PROGRAM_DOS ${CMAKE_MAKE_PROGRAM_DOS})

#
# Perl specific bat files
#
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"
  "pushd \"${PERL_SOURCE_DIR_DOS}\"
.\\miniperl.exe -I lib -MConfig -e \"print \$Config{archname}\" > tmpFile
SET /p perlarchname= < tmpFile
DEL tmpFile
popd
IF EXIST %USERPROFILE%\\.cpan\\.lock DEL /Q /F %USERPROFILE%\\.cpan\\.lock
set PATH=C:\\perl\\${PERL_VERSION}\\bin\\%perlarchname%;%PATH%
echo %* | perl -MCPAN -e shell"
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/perl-call.bat"
  "pushd \"${PERL_SOURCE_DIR_DOS}\"
.\\miniperl.exe -I lib -MConfig -e \"print \$Config{archname}\" > tmpFile
SET /p perlarchname= < tmpFile
DEL tmpFile
popd
set PATH=C:\\perl\\${PERL_VERSION}\\bin\\%perlarchname%;%PATH%
echo | perl %*"
)

#
# Download and build perl
#
ExternalProject_Add(perl
					PREFIX perl
					URL "https://www.cpan.org/src/5.0/perl-${PERL_VERSION}.tar.gz"
					SOURCE_DIR perl-${PERL_VERSION}
					SOURCE_SUBDIR win32
					#
					# One might think that putting environment CCTYPE is enough, but no. It fails near the end.
					# So let's follow perl recommandation, that is putting explicitly CCTYPE in the Makefile
					#
					PATCH_COMMAND     ${CMAKE_COMMAND} -E env "${PERLPATCH_BAT_DOS}" "${REPLACE_VBS_DOS}" "${PERL_SOURCE_DIR_DOS}" "${PERL_CCTYPE}" "${PERL_WIN64}"
					CONFIGURE_COMMAND ${CMAKE_COMMAND} -E echo "Configuration step skipped: using ${PERL_SOURCE_DIR_DOS}\\win32\\Makefile"
					# BUILD_COMMAND     ${CMAKE_MAKE_PROGRAM_DOS}
					# TEST_COMMAND      ${CMAKE_MAKE_PROGRAM_DOS} test
					#
					# Uncomment if you want to run make test only if explicitly required on the command-line
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					# TEST_BEFORE_INSTALL	TRUE
					BUILD_IN_SOURCE TRUE)

#
# Download and build nasm
#
set(NASM_SOURCE_DIR "nasm-${NASM_VERSION}")
add_custom_target(PerlFontTTF COMMENT "Perl module Font::TTF"           COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" install Font::TTF)
add_custom_target(PerlSortVersions COMMENT "Perl module Sort::Versions" COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" install Sort::Versions)
add_custom_target(PerlTextPatch COMMENT "Perl module Text::Patch"       COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" install Text::Patch)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/nasm-build.bat"
  "pushd \"${PERL_SOURCE_DIR_DOS}\"
.\\miniperl.exe -I lib -MConfig -e \"print \$Config{archname}\" > tmpFile
SET /p perlarchname= < tmpFile
DEL tmpFile
popd
set PATH=C:\\perl\\${PERL_VERSION}\\bin\\%perlarchname%;%PATH%
\"${CMAKE_MAKE_PROGRAM_DOS}\" -f Mkfiles\\msvc_patched.mak"
)

ExternalProject_Add(nasm
					PREFIX nasm
					DEPENDS PerlFontTTF PerlSortVersions PerlTextPatch
					URL "https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.gz"
					SOURCE_DIR ${NASM_SOURCE_DIR}
					#
					# C.f. https://forum.nasm.us/index.php?topic=2746.msg12335#msg12335
					#
					PATCH_COMMAND     "${CMAKE_CURRENT_BINARY_DIR}/perl-call.bat" "${PROJECT_SOURCE_DIR}/patch.pl" "Mkfiles/msvc.mak" "${PROJECT_SOURCE_DIR}/nasm_msvc_mak.diff" "Mkfiles/msvc_patched.mak"
					CONFIGURE_COMMAND ${CMAKE_COMMAND} -E echo "Configuration step skipped: using Mkfiles/msvc_patched.mak"
					BUILD_COMMAND     ${CMAKE_COMMAND} -E echo "Custom build step"
					COMMAND           ${CMAKE_COMMAND} -E rm -f asm/warnings.time
					COMMAND           ${CMAKE_COMMAND} -E touch asm/warnings.time
					COMMAND           "${CMAKE_CURRENT_BINARY_DIR}/nasm-build.bat"
					INSTALL_COMMAND   ${CMAKE_COMMAND} -E echo "Installation step skipped: leaving nasm.exe in its source tree"
					#
					# Uncomment if you want to run make test only if explicitly required on the command-line
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE TRUE)

#
# Download and build openssl. We want to install it in perl's "$Config{installbin}"
#
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-configure.bat"
  "pushd \"${PERL_SOURCE_DIR_DOS}\"
.\\miniperl.exe -I lib -MConfig -e \"print \$Config{archname}\" > tmpFile
SET /p perlarchname= < tmpFile
DEL tmpFile
popd
set PATH=C:\\perl\\${PERL_VERSION}\\bin\\%perlarchname%;%PATH%
set PATH=\"${CMAKE_CURRENT_BINARY_DIR}/${NASM_SOURCE_DIR}\";%PATH%
echo | perl -MConfig -e \"print \$Config{installbin}\" > tmpFile
SET /p perlinstallbin= < tmpFile
DEL tmpFile
rmdir /S /Q \"%perlinstallbin%\\openssl\"
SET LDFLAGS=${OPENSSL_LDFLAGS}
echo | perl Configure --prefix=\"%perlinstallbin%\\openssl\" --openssldir=\"%perlinstallbin%\\openssl\\SSL\" enable-fips enable-weak-ssl-ciphers %1")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-build.bat"
  "pushd \"${PERL_SOURCE_DIR_DOS}\"
.\\miniperl.exe -I lib -MConfig -e \"print \$Config{archname}\" > tmpFile
SET /p perlarchname= < tmpFile
DEL tmpFile
popd
set PATH=C:\\perl\\${PERL_VERSION}\\bin\\%perlarchname%;%PATH%
set PATH=\"${CMAKE_CURRENT_BINARY_DIR}/${NASM_SOURCE_DIR}\";%PATH%
\"${CMAKE_MAKE_PROGRAM_DOS}\"")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-install.bat"
  "pushd \"${PERL_SOURCE_DIR_DOS}\"
.\\miniperl.exe -I lib -MConfig -e \"print \$Config{archname}\" > tmpFile
SET /p perlarchname= < tmpFile
DEL tmpFile
popd
set PATH=C:\\perl\\${PERL_VERSION}\\bin\\%perlarchname%;%PATH%
set PATH=\"${CMAKE_CURRENT_BINARY_DIR}/${NASM_SOURCE_DIR}\";%PATH%
\"${CMAKE_MAKE_PROGRAM_DOS}\" install")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-test.bat"
  "pushd \"${PERL_SOURCE_DIR_DOS}\"
.\\miniperl.exe -I lib -MConfig -e \"print \$Config{archname}\" > tmpFile
SET /p perlarchname= < tmpFile
DEL tmpFile
popd
set PATH=C:\\perl\\${PERL_VERSION}\\bin\\%perlarchname%;%PATH%
set PATH=\"${CMAKE_CURRENT_BINARY_DIR}/${NASM_SOURCE_DIR}\";%PATH%
\"${CMAKE_MAKE_PROGRAM_DOS}\" test")
set(OPENSSL_SOURCE_DIR "openssl-${OPENSSL_VERSION}")
ExternalProject_Add(openssl
					PREFIX              openssl
					DEPENDS             perl nasm
					URL                 "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
					SOURCE_DIR          ${OPENSSL_SOURCE_DIR}
					CONFIGURE_COMMAND   "${CMAKE_CURRENT_BINARY_DIR}/openssl-configure.bat" "${OPENSSL_VC}"
					BUILD_COMMAND       "${CMAKE_CURRENT_BINARY_DIR}/openssl-build.bat"
					INSTALL_COMMAND     "${CMAKE_CURRENT_BINARY_DIR}/openssl-install.bat"
					TEST_COMMAND        "${CMAKE_CURRENT_BINARY_DIR}/openssl-test.bat"
					#
					# Uncomment if you want to run make test only if explicitly required on the command-line
					# On windows 70-test_comp.t is hanging, despite openssl seems ok. This is a bug in their test suite I strongly guess.
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					# TEST_BEFORE_INSTALL	TRUE
					BUILD_IN_SOURCE     TRUE)

#
# Install perl modules that need a patch - the others will be installed with normal cpan shell
#
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/perl-net-ssleay-configure.bat"
  "pushd \"${PERL_SOURCE_DIR_DOS}\"
.\\miniperl.exe -I lib -MConfig -e \"print \$Config{archname}\" > tmpFile
SET /p perlarchname= < tmpFile
DEL tmpFile
popd
set PATH=C:\\perl\\${PERL_VERSION}\\bin\\%perlarchname%;%PATH%
echo | perl -MConfig -e \"print \$Config{installbin} . '\\openssl'\" > tmpFile
SET /p opensslprefix= < tmpFile
DEL tmpFile
SET OPENSSL_PREFIX=%opensslprefix%
echo | perl Makefile.PL")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/perl-net-ssleay-test.bat"
  "pushd \"${PERL_SOURCE_DIR_DOS}\"
.\\miniperl.exe -I lib -MConfig -e \"print \$Config{archname}\" > tmpFile
SET /p perlarchname= < tmpFile
DEL tmpFile
popd
set PATH=C:\\perl\\${PERL_VERSION}\\bin\\%perlarchname%;%opensslprefix%\\bin;%PATH%
perl -MConfig -e \"print \$Config{installbin} . '\\openssl'\" > tmpFile
SET /p opensslprefix= < tmpFile
DEL tmpFile
echo | perl Makefile.PL")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/perl-net-ssleay-install.bat"
  "pushd \"${PERL_SOURCE_DIR_DOS}\"
.\\miniperl.exe -I lib -MConfig -e \"print \$Config{archname}\" > tmpFile
SET /p perlarchname= < tmpFile
DEL tmpFile
popd
set PATH=C:\\perl\\${PERL_VERSION}\\bin\\%perlarchname%;%PATH%
echo | perl -MConfig -e \"print \$Config{installbin}\" > tmpFile
SET /p perlinstallbin= < tmpFile
DEL tmpFile
\"${CMAKE_MAKE_PROGRAM_DOS}\" install
echo | perl -MConfig -e \"print \$Config{installbin} . '\\openssl'\" > tmpFile
SET /p opensslprefix= < tmpFile
DEL tmpFile
SET OPENSSL_PREFIX=%opensslprefix%
copy /Y %OPENSSL_PREFIX%\\bin\\libcrypto-3* %perlinstallbin%
copy /Y %OPENSSL_PREFIX%\\bin\\libssl-3* %perlinstallbin%")

set(PERL_NET_SSLEAY_SOURCE_DIR "perl-net-ssleay-${PERL_NET_SSLEAY_VERSION}")
ExternalProject_Add(perl-net-ssleay
					PREFIX              perl-net-ssleay
					DEPENDS             perl openssl
					URL                 "https://github.com/radiator-software/p5-net-ssleay/archive/refs/tags/${PERL_NET_SSLEAY_VERSION}.tar.gz"
					SOURCE_DIR          ${PERL_NET_SSLEAY_SOURCE_DIR}
					PATCH_COMMAND       "${CMAKE_CURRENT_BINARY_DIR}/perl-call.bat" "${PROJECT_SOURCE_DIR}/patch.pl" "SSLeay.xs" "${PROJECT_SOURCE_DIR}/SSLeay.xs.diff" "SSLeay.xs"
					CONFIGURE_COMMAND   "${CMAKE_CURRENT_BINARY_DIR}/perl-net-ssleay-configure.bat"
					BUILD_COMMAND       "${CMAKE_MAKE_PROGRAM_DOS}"
					TEST_COMMAND        "${CMAKE_CURRENT_BINARY_DIR}/perl-net-ssleay-test.bat"
					INSTALL_COMMAND     "${CMAKE_CURRENT_BINARY_DIR}/perl-net-ssleay-install.bat"
					#
					# Uncomment if you want to run make test only if explicitly required on the command-line
					#
					# TEST_EXCLUDE_FROM_MAIN TRUE
					TEST_BEFORE_INSTALL	TRUE
					BUILD_IN_SOURCE TRUE)

#
# Install cpanm assap
#
# TO DO

#
# Packages in trouble but force is ok
#
# Test suite is buggy, but this is ok. https://rt.cpan.org/Ticket/Display.html?id=127007
add_custom_target(PerlUnicodeUTF8 ALL DEPENDS perl-net-ssleay COMMENT "Perl module Unicode::UTF8" COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" force install Unicode::UTF8)

#
# Do quite like strawberry perl
#
foreach(_package
        Capture::Tiny
		Path::Tiny
		TAP::Harness::Restricted
		# IPC-Run - Total failure with cl...
		IPC::System::Simple
		IPC::Run3
		Mozilla::CA
		IO::Socket::SSL
		LWP
		LWP::Protocol::https
		App::cpanminus
		)
  set (_targetName ${_package})
  string (REGEX REPLACE "::" "" _targetName ${_targetName})
  add_custom_target(${_targetName} ALL DEPENDS perl-net-ssleay COMMENT "Perl module ${_package}" COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" install ${_package})
endforeach ()

#
# Install everything else that makes it a good distribution
#
# Some "monster but portable and definitely must have" packages.
# A lot of very good stuff will be installed as dependencies.
# 
add_custom_target(PerlCPANDistnameInfo ALL DEPENDS perl-net-ssleay COMMENT "Perl module CPAN::DistnameInfo" COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" install CPAN::DistnameInfo)
add_custom_target(PerlDistZilla ALL DEPENDS perl-net-ssleay COMMENT "Perl module Dist::Zilla" COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" install Dist::Zilla)
