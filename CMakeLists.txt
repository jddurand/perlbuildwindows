#
# Example: cmake -G "NMake Makefiles" -DPERL_VERSION=5.36.0 .
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
option(PERL_VERSION "Perl version")
option(OPENSSL_VERSION "Openssl version")
option(NASM_VERSION "Nasm version")
option(PERL_NET_SSLEAY_VERSION "Perl Net::SSLeay version")
#
# Guess default CCTYPE
#
if (NOT MSVC)
  message(FATAL_ERROR "Compiler must be MSVC")
endif()
if (MSVC12)
  set(CCTYPE "MSVC120")
elseif (MSVC_VERSION LESS 1910)
  set(CCTYPE "MSVC140")
elseif (MSVC_VERSION LESS 1920)
  set(CCTYPE "MSVC141")
elseif (MSVC_VERSION LESS 1930)
  set(CCTYPE "MSVC142")
elseif (MSVC_VERSION LESS 1940)
  set(CCTYPE "MSVC143")
elseif (MSVC_VERSION LESS 1800)
  #
  # Perl's Makefile says that only MSVC 120 and higher is supported
  #
  message(FATAL_ERROR "MSVC_VERSION ${MSVC_VERSION} is too old")
endif()
option(CCTYPE "Compiler type")
if (NOT CCTYPE)
	message(FATAL_ERROR "CCTYPE is required, e.g. -DCCTYPE=MSVC143 for VS2022 Community Edition. Please refer to perl win32/Makefile file.")
endif ()

if (NOT PERL_VERSION)
	message(FATAL_ERROR "PERL_VERSION is required, e.g. -DPERL_VERSION=5.36.0")
endif ()
if (NOT OPENSSL_VERSION)
	SET (OPENSSL_VERSION 3.0.5)
endif ()
if (NOT NASM_VERSION)
	SET (NASM_VERSION 2.15.05)
endif ()
if (NOT PERL_NET_SSLEAY_VERSION)
	SET (PERL_NET_SSLEAY_VERSION 1.93_01)
endif ()

include(ExternalProject)

#
# Download and build perl
#
set(PERL_SOURCE_DIR "perl-${PERL_VERSION}")
ExternalProject_Add(perl
					PREFIX perl
					URL "https://www.cpan.org/src/5.0/perl-${PERL_VERSION}.tar.gz"
					SOURCE_DIR ${PERL_SOURCE_DIR}
					SOURCE_SUBDIR win32
					#
					# One might think that putting environment CCTYPE is enough, but no. It fails near the end.
					# So let's follow perl recommandation, that is putting explicitly CCTYPE in the Makefile
					#
					PATCH_COMMAND     ${CMAKE_COMMAND} -E env "${PROJECT_SOURCE_DIR}/perlpatch.bat" "${PROJECT_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}/${PERL_SOURCE_DIR}" "${CCTYPE}"
					CONFIGURE_COMMAND ${CMAKE_COMMAND} -E echo "Configuration step skipped: using win32/Makefile"
					BUILD_COMMAND     nmake
					#
					# We want to run make test only if explicitly required on the command-line
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE TRUE)
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
  set (PERL_EXE "C:/perl/${PERL_VERSION}/bin/MSWin32-x64-multi-thread/perl.exe")
  set (PERL_PATH "C:/perl/${PERL_VERSION}/bin/MSWin32-x64-multi-thread")
else ()
  set (PERL_EXE "C:/perl/${PERL_VERSION}/bin/MSWin32-x86-multi-thread/perl.exe")
  set (PERL_PATH "C:/perl/${PERL_VERSION}/bin/MSWin32-x86-multi-thread")
endif ()
message(STATUS "Perl executable is: ${PERL_EXE}")

set (PERL_CPAN "C:/perl/${PERL_VERSION}/bin/cpan.bat")
#
# Perl dependencies to build nasm - we know where perl was installed: C:\perl\${
#
add_custom_target(PerlFontTTF
                  COMMENT "Perl module Font::TTF"
				  COMMAND ${PERL_EXE} -MCPAN -e \"CPAN::Shell->install('Font::TTF')\")
add_custom_target(PerlSortVersions
                  COMMENT "Perl module Sort::Versions"
                  COMMAND ${PERL_EXE} -MCPAN -e \"CPAN::Shell->install('Sort::Versions')\")
add_custom_target(PerlTextPatch
                  COMMENT "Perl module Text::Patch"
                  COMMAND ${PERL_EXE} -MCPAN -e \"CPAN::Shell->install('Text::Patch')\")

#
# Download and build nasm
#
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/nasm-build.bat"
  "set PATH=\"${PERL_PATH}\";%PATH%
nmake -f Mkfiles\\msvc_patched.mak")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/nasm-install.bat"
  "set PATH=\"${PERL_PATH}\";%PATH%
nmake -f Mkfiles\\msvc_patched.mak install")
set(NASM_SOURCE_DIR "nasm-${NASM_VERSION}")
ExternalProject_Add(nasm
					PREFIX nasm
					DEPENDS PerlFontTTF PerlSortVersions PerlTextPatch
					URL "https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.gz"
					SOURCE_DIR ${NASM_SOURCE_DIR}
					#
					# C.f. https://forum.nasm.us/index.php?topic=2746.msg12335#msg12335
					#
					PATCH_COMMAND     ${PERL_EXE} "${PROJECT_SOURCE_DIR}/patch.pl" "${PROJECT_SOURCE_DIR}/${NASM_SOURCE_DIR}/Mkfiles/msvc.mak" "${PROJECT_SOURCE_DIR}/nasm_msvc_mak.diff" "${PROJECT_SOURCE_DIR}/${NASM_SOURCE_DIR}/Mkfiles/msvc_patched.mak"
					CONFIGURE_COMMAND ${CMAKE_COMMAND} -E echo "Configuration step skipped: using Mkfiles/msvc_patched.mak"
					BUILD_COMMAND     ${CMAKE_COMMAND} -E echo "Custom build step"
					COMMAND           ${CMAKE_COMMAND} -E rm -f asm/warnings.time
					COMMAND           ${CMAKE_COMMAND} -E touch asm/warnings.time
					COMMAND           "${CMAKE_CURRENT_BINARY_DIR}/nasm-build.bat"
					INSTALL_COMMAND   ${CMAKE_COMMAND} -E echo "Installation step skipped: leaving nasm.exe in its source tree"
					#
					# We want to run make test only if explicitly required on the command-line
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE TRUE)

#
# Download and build openssl. We want to install it in perl's "$Config{installbin}"
#
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-configure.bat"
  "set PATH=\"${PERL_PATH}\";%PATH%
set CC=cl
set PATH=\"${PROJECT_SOURCE_DIR}/${NASM_SOURCE_DIR}\";%PATH%
perl -MConfig -e \"print \$Config{installbin}\" > tmpFile
SET /p perlinstallbin= < tmpFile
DEL tmpFile
perl Configure --prefix=\"%perlinstallbin%/openssl\" --openssldir=\"%perlinstallbin%/openssl/SSL\"")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-build.bat"
  "set PATH=\"${PERL_PATH}\";%PATH%
set PATH=\"${PROJECT_SOURCE_DIR}/${NASM_SOURCE_DIR}\";%PATH%
nmake")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-install.bat"
  "set PATH=\"${PERL_PATH}\";%PATH%
set PATH=\"${PROJECT_SOURCE_DIR}/${NASM_SOURCE_DIR}\";%PATH%
nmake install")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-test.bat"
  "set PATH=\"${PERL_PATH}\";%PATH%
set PATH=\"${PROJECT_SOURCE_DIR}/${NASM_SOURCE_DIR}\";%PATH%
nmake test")
set(OPENSSL_SOURCE_DIR "openssl-${OPENSSL_VERSION}")
ExternalProject_Add(openssl
					PREFIX openssl
					DEPENDS perl nasm
					URL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
					SOURCE_DIR ${OPENSSL_SOURCE_DIR}
					CONFIGURE_COMMAND "${CMAKE_CURRENT_BINARY_DIR}/openssl-configure.bat"
					BUILD_COMMAND     "${CMAKE_CURRENT_BINARY_DIR}/openssl-build.bat"
					INSTALL_COMMAND   "${CMAKE_CURRENT_BINARY_DIR}/openssl-install.bat"
					TEST_COMMAND      "${CMAKE_CURRENT_BINARY_DIR}/openssl-test.bat"
					#
					# We want to run make test only if explicitly required on the command-line
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE TRUE)

#
# Install perl modules that need a patch - the others will be installed with normal cpan shell
#
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/perl-net-ssleay-configure.bat"
  "set PATH=\"${PERL_PATH}\";%PATH%
perl -MConfig -e \"print \$Config{installbin} . '\\openssl'\" > tmpFile
SET /p opensslinstallbin= < tmpFile
DEL tmpFile
SET OPENSSL_PREFIX=%opensslinstallbin%
echo | perl Makefile.PL")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/perl-net-ssleay-install.bat"
  "set PATH=\"${PERL_PATH}\";%PATH%
perl -MConfig -e \"print \$Config{installbin} . '\\openssl'\" > tmpFile
SET /p opensslinstallbin= < tmpFile
DEL tmpFile
perl -MConfig -e \"print \$Config{installbin}\" > tmpFile
SET /p perlinstallbin= < tmpFile
DEL tmpFile
SET OPENSSL_PREFIX=%opensslinstallbin%
SET PERL_INSTALLBIN=%perlinstallbin%
nmake install
copy /Y %OPENSSL_PREFIX%\\bin\\libcrypto-3* %PERL_INSTALLBIN%
copy /Y %OPENSSL_PREFIX%\\bin\\libssl-3* %PERL_INSTALLBIN%")
set(PERL_NET_SSLEAY_SOURCE_DIR "perl-net-ssleay-${PERL_NET_SSLEAY_VERSION}")
ExternalProject_Add(perl-net-ssleay
					PREFIX perl-net-ssleay
					DEPENDS perl
					URL "https://github.com/radiator-software/p5-net-ssleay/archive/refs/tags/${PERL_NET_SSLEAY_VERSION}.tar.gz"
					SOURCE_DIR ${PERL_NET_SSLEAY_SOURCE_DIR}
					PATCH_COMMAND     ${PERL_EXE} "${PROJECT_SOURCE_DIR}/patch.pl" "${PROJECT_SOURCE_DIR}/${PERL_NET_SSLEAY_SOURCE_DIR}/SSLeay.xs" "${PROJECT_SOURCE_DIR}/SSLeay.xs.diff" "${PROJECT_SOURCE_DIR}/${PERL_NET_SSLEAY_SOURCE_DIR}/SSLeay.xs"
					CONFIGURE_COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-net-ssleay-configure.bat"
					BUILD_COMMAND     nmake
					INSTALL_COMMAND   "${CMAKE_CURRENT_BINARY_DIR}/perl-net-ssleay-install.bat"
					TEST_COMMAND      nmake test
					#
					# We want to run make test only if explicitly required on the command-line
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE TRUE)

