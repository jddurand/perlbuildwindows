cmake_minimum_required(VERSION 3.12)

project(fribidi)

add_definitions(-D_CRT_SECURE_NO_WARNINGS -DHAVE_STRINGIZE)

include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckTypeSize)
check_include_files("stdlib.h;stdarg.h;string.h;float.h" STDC_HEADERS)
check_include_file("stdlib.h" HAVE_STDLIB_H)
check_include_file("string.h" HAVE_STRING_H)
check_include_file("memory.h" HAVE_MEMORY_H)
check_include_file("string.h" HAVE_STRING_H)
check_include_file("strings.h" HAVE_STRINGS_H)
check_include_file("sys/times.h" HAVE_SYS_TIMES_H)
check_type_size(int SIZEOF_INT)

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(lib)

function(extract_regex_1 var text regex)
	string(REGEX MATCH ${regex} _ ${text})
	set(${var} "${CMAKE_MATCH_1}" PARENT_SCOPE)
endfunction()


file(READ configure.ac FRIBIDI_CONF)
extract_regex_1(FRIBIDI_MAJOR_VERSION     "${FRIBIDI_CONF}" "\\(fribidi_major_version, ([0-9]+)\\)")
extract_regex_1(FRIBIDI_MINOR_VERSION     "${FRIBIDI_CONF}" "\\(fribidi_minor_version, ([0-9]+)\\)")
extract_regex_1(FRIBIDI_MICRO_VERSION     "${FRIBIDI_CONF}" "\\(fribidi_micro_version, ([0-9]+)\\)")
extract_regex_1(FRIBIDI_INTERFACE_VERSION "${FRIBIDI_CONF}" "\\(fribidi_interface_version, ([0-9]+)\\)")
extract_regex_1(FRIBIDI_INTERFACE_AGE     "${FRIBIDI_CONF}" "\\(fribidi_interface_age, ([0-9]+)\\)")
extract_regex_1(FRIBIDI_BINARY_AGE        "${FRIBIDI_CONF}" "\\(fribidi_binary_age, ([0-9]+)\\)")
set(FRIBIDI_VERSION "${FRIBIDI_MAJOR_VERSION}.${FRIBIDI_MINOR_VERSION}.${FRIBIDI_MICRO_VERSION}")
set(PACKAGE "fribidi")
set(PACKAGE_NAME "GNU FriBidi")
set(PACKAGE_BUGREPORT "https://github.com/fribidi/fribidi/issues/new")
if (MSVC)
	set(FRIBIDI_MSVC_BUILD_PLACEHOLDER "#define FRIBIDI_BUILT_WITH_MSVC")
endif ()
message("detected ${PACKAGE_NAME} version ${FRIBIDI_VERSION}")
configure_file(lib/fribidi-config.h.in lib/fribidi-config.h @ONLY)

function(prepend var prefix)
	set(out "")
	foreach(f ${ARGN})
		list(APPEND out "${prefix}${f}")
	endforeach()
	set(${var} "${out}" PARENT_SCOPE)
endfunction()

macro(fribidi_definitions _TGT)
	if (STDC_HEADERS)
		target_compile_definitions(${_TGT} PUBLIC STDC_HEADERS)
	endif ()
	if (HAVE_STDLIB_H)
		target_compile_definitions(${_TGT} PUBLIC HAVE_STDLIB_H)
	endif ()
	if (HAVE_STRING_H)
		target_compile_definitions(${_TGT} PUBLIC HAVE_STRING_H)
	endif ()
	if (HAVE_MEMORY_H)
		target_compile_definitions(${_TGT} PUBLIC HAVE_MEMORY_H)
	endif ()
	if (HAVE_STRING_H)
		target_compile_definitions(${_TGT} PUBLIC HAVE_STRING_H)
	endif ()
	if (HAVE_STRINGS_H)
		target_compile_definitions(${_TGT} PUBLIC HAVE_STRINGS_H)
	endif ()
	if (HAVE_SYS_TIMES_H)
		target_compile_definitions(${_TGT} PUBLIC HAVE_SYS_TIMES_H)
	endif ()
	#
	# Available pretty much everywhere and needed anyway...
	#
	target_compile_definitions(${_TGT} PUBLIC HAVE_STRINGIZE)
endmacro()

function(fribidi_gen _NAME _OUTNAME _PARAM)
	set(_OUT lib/${_OUTNAME})
	prepend(_DEP "${CMAKE_CURRENT_SOURCE_DIR}/gen.tab/" ${ARGN})
	add_executable(gen-${_NAME}
		gen.tab/gen-${_NAME}.c
		gen.tab/packtab.c)
	fribidi_definitions(gen-${_NAME})
	target_compile_definitions(gen-${_NAME}
		PUBLIC DONT_HAVE_FRIBIDI_CONFIG_H)
	add_custom_command(
		COMMAND gen-${_NAME} ${_PARAM} ${_DEP} > ${_OUT}
		DEPENDS ${_DEP}
		OUTPUT ${_OUT})
	list(APPEND FRIBIDI_SOURCES_GENERATED "${_OUT}")
	set(FRIBIDI_SOURCES_GENERATED ${FRIBIDI_SOURCES_GENERATED} PARENT_SCOPE)
endfunction()

fribidi_gen(unicode-version fribidi-unicode-version.h ""
	unidata/ReadMe.txt unidata/BidiMirroring.txt)


macro(fribidi_tab _NAME)
	fribidi_gen(${_NAME}-tab ${_NAME}.tab.i 2 ${ARGN})
	target_sources(gen-${_NAME}-tab
		PRIVATE lib/fribidi-unicode-version.h)
endmacro()

fribidi_tab(bidi-type unidata/UnicodeData.txt)
fribidi_tab(joining-type unidata/UnicodeData.txt unidata/ArabicShaping.txt)
fribidi_tab(arabic-shaping unidata/UnicodeData.txt)
fribidi_tab(mirroring unidata/BidiMirroring.txt)
fribidi_tab(brackets unidata/BidiBrackets.txt unidata/UnicodeData.txt)
fribidi_tab(brackets-type unidata/BidiBrackets.txt)


file(GLOB FRIBIDI_SOURCES lib/*.c)
file(GLOB FRIBIDI_HEADERS lib/*.h)

add_library(fribidi SHARED
	${FRIBIDI_SOURCES}
	${FRIBIDI_HEADERS}
	${FRIBIDI_SOURCES_GENERATED})
target_compile_definitions(fribidi PRIVATE -DFRIBIDI_BUILD)
set(public_headers
	lib/fribidi-arabic.h
	lib/fribidi-begindecls.h
	lib/fribidi-bidi-types-list.h
	lib/fribidi-bidi-types.h
	lib/fribidi-bidi.h
	lib/fribidi-brackets.h
	lib/fribidi-char-sets-list.h
	lib/fribidi-char-sets.h
	lib/fribidi-common.h
	lib/fribidi-config.h
	lib/fribidi-deprecated.h
	lib/fribidi-enddecls.h
	lib/fribidi-flags.h
	lib/fribidi-joining-types-list.h
	lib/fribidi-joining-types.h
	lib/fribidi-joining.h
	lib/fribidi-mirroring.h
	lib/fribidi-shape.h
	lib/fribidi-types.h
	lib/fribidi-unicode-version.h
	lib/fribidi-unicode.h
	lib/fribidi.h
)
set_target_properties(fribidi
    PROPERTIES
    VERSION       "${FRIBIDI_MAJOR_VERSION}.${FRIBIDI_MINOR_VERSION}.${FRIBIDI_MICRO_VERSION}"
    SOVERSION     "${FRIBIDI_MAJOR_VERSION}"
	PUBLIC_HEADER "${public_headers}"
    )
install(TARGETS fribidi PUBLIC_HEADER DESTINATION include/fribidi)

# For pkgconfig
# We follow debian convention i.e. pkgconfig directory is sibbling to lib, dir and include directories
set(prefix      "\${pcfiledir}/../..")
set(exec_prefix "\${prefix}")
set(libdir      "\${exec_prefix}/lib")
set(includedir  "\${prefix}/include")
set(VERSION     ${FRIBIDI_VERSION})
set(ENABLE_SHARED_TRUE "")
set(ENABLE_SHARED_FALSE "#")
set(FRIBIDI_CPPFLAGS "-DFRIBIDI_BUILD")
# freebidi.pc assumes that compiler/linker uses -L, -l and -I.
# Make sure we replace them by current settings
CONFIGURE_FILE("fribidi.pc.in" "fribidi.pc" @ONLY)
install(FILES fribidi.pc DESTINATION lib/pkgconfig)
