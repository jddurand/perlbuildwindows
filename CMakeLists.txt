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
# Get list of stable perl versions
#
file(DOWNLOAD https://raw.githubusercontent.com/skaji/perl-releases/main/perl-releases.v1.csv
     TIMEOUT  30
	 "${CMAKE_CURRENT_BINARY_DIR}/perl-releases.v1.csv")
file(STRINGS "${CMAKE_CURRENT_BINARY_DIR}/perl-releases.v1.csv" perl_stable_relases REGEX ",stable,")
set(PERL_VERSIONS)
foreach(perl_stable_relase ${perl_stable_relases})
  string(REPLACE "," ";" perl_stable_relase ${perl_stable_relase})
  list(GET perl_stable_relase 2 perl_stable_release_version)
  list(APPEND PERL_VERSIONS ${perl_stable_release_version})
endforeach()

list(LENGTH PERL_VERSIONS PERL_VERSIONS_length)
if (PERL_VERSIONS_length GREATER 0)
  list(GET PERL_VERSIONS 0 PERL_VERSION_DEFAULT)
else ()
  set (PERL_VERSION_DEFAULT OFF)
endif ()

set (PERL_TEST                       FALSE)
set (OPENSSL_VERSION_DEFAULT         3.0.5)
set (NASM_VERSION_DEFAULT            2.15.05)
set (PERL_NET_SSLEAY_VERSION_DEFAULT 1.93_01)

set (PERL_INST_DRV           ${PERL_INST_DRV_DEFAULT}           CACHE STRING "Perl installation drive")
set (PERL_VERSION            ${PERL_VERSION_DEFAULT}            CACHE STRING "Perl version")
set (PERL_TEST               OFF                                CACHE STRING "Perl test")
set (OPENSSL_VERSION         ${OPENSSL_VERSION_DEFAULT}         CACHE STRING "Openssl version")
set (NASM_VERSION            ${NASM_VERSION_DEFAULT}            CACHE STRING "Nasm version")
set (PERL_NET_SSLEAY_VERSION ${PERL_NET_SSLEAY_VERSION_DEFAULT} CACHE STRING "Perl's Net::SSLeay version")

set_property (CACHE PERL_INST_DRV PROPERTY STRINGS           ${drives} )
set_property (CACHE PERL_VERSION PROPERTY STRINGS            ${PERL_VERSIONS})
set_property (CACHE PERL_TEST PROPERTY STRINGS               ON OFF)
set_property (CACHE OPENSSL_VERSION PROPERTY STRINGS         ${OPENSSL_VERSION_DEFAULT})
set_property (CACHE NASM_VERSION PROPERTY STRINGS            ${NASM_VERSION_DEFAULT})
set_property (CACHE PERL_NET_SSLEAY_VERSION PROPERTY STRINGS ${PERL_NET_SSLEAY_VERSION_DEFAULT})

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

set (PERL_SOURCE_DIR_DOS "${CMAKE_CURRENT_BINARY_DIR}/perl-${PERL_VERSION}")
string (REGEX REPLACE "/" "\\\\" PERL_SOURCE_DIR_DOS ${PERL_SOURCE_DIR_DOS})

set (CMAKE_MAKE_PROGRAM_DOS "${CMAKE_MAKE_PROGRAM}")
string (REGEX REPLACE "/" "\\\\" CMAKE_MAKE_PROGRAM_DOS ${CMAKE_MAKE_PROGRAM_DOS})

set (CMAKE_COMMAND_DOS "${CMAKE_COMMAND}")
string (REGEX REPLACE "/" "\\\\" CMAKE_COMMAND_DOS ${CMAKE_COMMAND_DOS})

#
# Perl specific bat files
#
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat"
"IF EXIST %USERPROFILE%\\.cpan\\.lock DEL /Q /F %USERPROFILE%\\.cpan\\.lock
set PATH=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\bin;%PATH%
echo | cpan %*
")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/perl-cpanm.bat"
"IF EXIST %USERPROFILE%\\.cpan\\.lock DEL /Q /F %USERPROFILE%\\.cpan\\.lock
set PATH=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\bin;%PATH%
echo | cpanm %*
")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/perl-call.bat"
"set PATH=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\bin;%PATH%
echo | perl %*
")

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
					PATCH_COMMAND     ${CMAKE_COMMAND} -E env "${PERLPATCH_BAT_DOS}" "${REPLACE_VBS_DOS}" "${PERL_SOURCE_DIR_DOS}" "${PERL_CCTYPE}" "${PERL_WIN64}" "${PERL_INSTSUBDIR}" "${PERL_INST_DRV}"
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
# We want to install PerlCPANDistnameInfo as soon as possible
#
add_custom_target(PerlCPANDistnameInfo
                  COMMENT "Perl module CPAN::DistnameInfo"
				  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" CPAN::DistnameInfo)

#
# Download and build nasm
#
set(NASM_SOURCE_DIR "nasm-${NASM_VERSION}")
set (NASM_SOURCE_DIR_DOS "${NASM_SOURCE_DIR}")
string (REGEX REPLACE "/" "\\\\" NASM_SOURCE_DIR_DOS ${NASM_SOURCE_DIR_DOS})

add_custom_target(PerlFontTTF
                  COMMENT "Perl module Font::TTF"
				  DEPENDS PerlCPANDistnameInfo
				  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" Font::TTF)
add_custom_target(PerlSortVersions
                  COMMENT "Perl module Sort::Versions"
				  DEPENDS PerlCPANDistnameInfo
				  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" Sort::Versions)
add_custom_target(PerlTextPatch
                  COMMENT "Perl module Text::Patch"
				  DEPENDS PerlCPANDistnameInfo
				  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" Text::Patch)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/nasm-build.bat"
"set PATH=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\bin;%PATH%
echo | \"${CMAKE_MAKE_PROGRAM_DOS}\" -f Mkfiles\\msvc_patched.mak
")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/nasm-install.bat"
"set PATH=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\bin;%PATH%
if not exist \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\" mkdir \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\"
copy /Y \"rdoff\\ldrdf.exe\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\"
copy /Y \"nasm.exe\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\"
copy /Y \"ndisasm.exe\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\"
copy /Y \"rdoff\\rdf2bin.exe\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\"
copy /Y \"rdoff\\rdf2com.exe\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\"
copy /Y \"rdoff\\rdf2ihx.exe\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\"
copy /Y \"rdoff\\rdf2ith.exe\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\"
copy /Y \"rdoff\\rdf2srec.exe\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\"
copy /Y \"rdoff\\rdfdump.exe\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\"
copy /Y \"rdoff\\rdflib.exe\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\"
copy /Y \"rdoff\\rdx.exe\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\bin\"
if not exist \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\license\" mkdir \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\license\"
if not exist \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\license\\nasm\" mkdir \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\license\\nasm\"
copy /Y \"LICENSE\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\license\\nasm\"
if not exist \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\" mkdir \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\"
if not exist \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\" mkdir \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\"
copy /Y \"rdoff\\ldrdf.1\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\"
copy /Y \"nasm.1\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\"
copy /Y \"ndisasm.1\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\"
copy /Y \"rdoff\\rdf2bin.1\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\"
copy /Y \"rdoff\\rdf2com.1\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\"
copy /Y \"rdoff\\rdf2ihx.1\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\"
copy /Y \"rdoff\\rdf2ith.1\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\"
copy /Y \"rdoff\\rdf2srec.1\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\"
copy /Y \"rdoff\\rdfdump.1\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\"
copy /Y \"rdoff\\rdflib.1\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\"
copy /Y \"rdoff\\rdx.1\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\man\\man1\"
if not exist \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\lib\" mkdir \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\lib\"
copy /Y \"rdoff\\librdoff.lib\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\lib\"
copy /Y \"libnasm.lib\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\lib\"
")

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
					INSTALL_COMMAND           "${CMAKE_CURRENT_BINARY_DIR}/nasm-install.bat" "${NASM_SOURCE_DIR}"
					# INSTALL_COMMAND   ${CMAKE_COMMAND} -E echo "Installation step skipped: leaving nasm.exe in its source tree"
					#
					# Uncomment if you want to run make test only if explicitly required on the command-line
					#
					TEST_EXCLUDE_FROM_MAIN TRUE
					BUILD_IN_SOURCE TRUE)

#
# Download and build openssl. We want to install it in perl's "$Config{installbin}"
#
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-configure.bat"
"set PATH=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\bin;%PATH%
set PATH=\"${CMAKE_CURRENT_BINARY_DIR}/${NASM_SOURCE_DIR}\";%PATH%
SET LDFLAGS=${OPENSSL_LDFLAGS}
echo | perl Configure --prefix=\"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\" --openssldir=\"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c\\SSL\" enable-fips enable-weak-ssl-ciphers %1
")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-build.bat"
"set PATH=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\bin;%PATH%
set PATH=\"${CMAKE_CURRENT_BINARY_DIR}/${NASM_SOURCE_DIR}\";%PATH%
echo | \"${CMAKE_MAKE_PROGRAM_DOS}\"
")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-install.bat"
"set PATH=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\bin;%PATH%
set PATH=\"${CMAKE_CURRENT_BINARY_DIR}/${NASM_SOURCE_DIR}\";%PATH%
echo | \"${CMAKE_MAKE_PROGRAM_DOS}\" install
")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/openssl-test.bat"
"set PATH=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\bin;%PATH%
set PATH=\"${CMAKE_CURRENT_BINARY_DIR}/${NASM_SOURCE_DIR}\";%PATH%
echo | \"${CMAKE_MAKE_PROGRAM_DOS}\" test
")
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
"set PATH=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\bin;%PATH%
SET OPENSSL_PREFIX=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c
echo | perl Makefile.PL
")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/perl-net-ssleay-test.bat"
"set PATH=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\bin;%PATH%
SET OPENSSL_PREFIX=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c
set PATH=%OPENSSL_PREFIX%\\bin;%PATH%
echo | \"${CMAKE_MAKE_PROGRAM_DOS}\" test
")

#
# TO DO: Instead copy the openssl libs in C:\cl-perl-5.36.0-32bit\site\lib\auto\Net\SSLeay ?
#
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/perl-net-ssleay-install.bat"
"set PATH=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\bin;%PATH%
SET OPENSSL_PREFIX=${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\c
echo | \"${CMAKE_MAKE_PROGRAM_DOS}\" install
copy /Y \"%OPENSSL_PREFIX%\\bin\\libcrypto-3*\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\site\\lib\\auto\\Net\\SSLeay\"
copy /Y \"%OPENSSL_PREFIX%\\bin\\libssl-3*\" \"${PERL_INST_DRV}\\${PERL_INSTSUBDIR}\\site\\lib\\auto\\Net\\SSLeay\"
")

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
add_custom_target(PerlAppcpanminus
                  ALL
				  DEPENDS perl-net-ssleay
				  COMMENT "Perl module App::cpanminus"
				  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpan.bat" App::cpanminus)

#
# Install distributions that are ok but where tests are buggy
#
add_custom_target(Forced
                  ALL
				  DEPENDS PerlAppcpanminus
				  COMMENT "Perl module using cpanm --notest"
				  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpanm.bat"
				  --notest
				  Unicode::UTF8 # https://rt.cpan.org/Dist/Display.html?Name=Unicode-UTF8
				  Test::File # https://github.com/briandfoy/test-file/issues/36
				  )

#
# Install distributions that must be completely ok
#
add_custom_target(Ok
                  ALL
				  DEPENDS Forced
				  COMMENT "Perl module using cpanm"
				  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/perl-cpanm.bat"
				  MarpaX::ESLIF
				  )
