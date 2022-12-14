cmake_minimum_required(VERSION 3.12)

project(thai VERSION 0.1.29)

#
# Dependency on datrie
#
find_package(PkgConfig REQUIRED)
pkg_check_modules(DATRIE REQUIRED datrie-0.2)
message(STATUS "DATRIE_INCLUDE_DIRS : ${DATRIE_INCLUDE_DIRS}")
message(STATUS "DATRIE_LIBRARY_DIRS : ${DATRIE_LIBRARY_DIRS}")
message(STATUS "DATRIE_LIBRARIES    : ${DATRIE_LIBRARIES}")

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/thai.def
  COMMAND ${CMAKE_COMMAND} -E rm -f ${CMAKE_CURRENT_BINARY_DIR}/thai.def
  COMMAND ${CMAKE_COMMAND} -E echo EXPORTS > ${CMAKE_CURRENT_BINARY_DIR}/thai.def
  COMMAND ${CMAKE_COMMAND} -E cat src/libthai.def >> ${CMAKE_CURRENT_BINARY_DIR}/thai.def
  )

add_library(thai SHARED
	src/libthai.c
	src/thctype/thctype.c src/thctype/wtt.c
	src/thstr/thstr.c
	src/thcell/thcell.c
	src/thinp/thinp.c
	src/thrend/thrend.c
	src/thcoll/cweight.c src/thcoll/thcoll.c
	src/thbrk/thbrk.c src/thbrk/brk-ctype.c src/thbrk/brk-common.c src/thbrk/brk-maximal.c
	src/thwchar/thwchar.c
	src/thwctype/thwctype.c
	src/thwstr/thwstr.c
	src/thwbrk/thwbrk.c
	${CMAKE_CURRENT_BINARY_DIR}/thai.def
	)

target_compile_definitions(thai PRIVATE -D_CRT_SECURE_NO_WARNINGS -DTHAI_BUILD)
target_include_directories(thai PRIVATE include ${DATRIE_INCLUDE_DIRS})
target_link_directories(thai PRIVATE ${DATRIE_LIBRARY_DIRS})
target_link_libraries(thai PUBLIC ${DATRIE_LIBRARIES})

set(public_headers
    include/thai/thailib.h
    include/thai/thbrk.h
    include/thai/thcell.h
    include/thai/thcoll.h
    include/thai/thctype.h
    include/thai/thinp.h
    include/thai/thrend.h
    include/thai/thstr.h
    include/thai/thwbrk.h
    include/thai/thwchar.h
    include/thai/thwcoll.h
    include/thai/thwctype.h
    include/thai/thwinp.h
    include/thai/thwrend.h
    include/thai/thwstr.h
    include/thai/tis.h
    include/thai/wtt.h
)

set_target_properties(thai
    PROPERTIES
    VERSION       "${THAI_MAJOR_VERSION}.${THAI_MINOR_VERSION}.${THAI_MICRO_VERSION}"
    SOVERSION     "${THAI_MAJOR_VERSION}"
	PUBLIC_HEADER "${public_headers}"
    )
install(TARGETS thai PUBLIC_HEADER DESTINATION include/thai)

# thbrk.tri
find_program(PERL perl)
if(NOT PERL)
  message(FATAL_ERROR "No perl in path")
endif()
find_program(TRIETOOL trietool)
if(NOT TRIETOOL)
  message(FATAL_ERROR "No trietool in path")
endif()
file(GLOB TDICT_SRC data/*.txt)
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/binconcat.pl [=[#!env perl
use strict;
use diagnostics;

my $output = shift(@ARGV);

print "Binary concat to $output\n";

open(OUTPUT, '>', $output) || die "Cannot open $output, $!";
binmode OUTPUT;
my $total = 0;

foreach my $input (@ARGV) {
  open(INPUT, '<', $input) || die "Cannot open $input, $!";
  binmode INPUT;
  my $content = do { local $/; <INPUT> };
  close(INPUT) || warn "Cannot close $input, $!";
  my $length = length($content);
  printf STDOUT "..... %s : %d bytes\n", $input, $length;
  print OUTPUT $content;
  $total += $length;
}
printf STDOUT "Total %s : %d bytes\n", $output, $total;

close(OUTPUT) || warn "Cannot close $output, $!";

exit(0);
]=])
add_custom_command(OUTPUT data/tdict.txt
                   COMMAND ${PERL} ${CMAKE_CURRENT_BINARY_DIR}/binconcat.pl data/tdict.txt ${TDICT_SRC}
				   DEPENDS ${TDICT_SRC})
add_custom_command(OUTPUT data/thbrk.tri
                   WORKING_DIRECTORY data
                   COMMAND ${TRIETOOL} -p . thbrk add-list -e utf-8 tdict.txt
				   DEPENDS data/tdict.txt data/thbrk.abm)
add_custom_command(OUTPUT share/libthai/thbrk.tri
                   COMMAND ${CMAKE_COMMAND} -E rm -rf share/libthai
				   COMMAND ${CMAKE_COMMAND} -E copy data/thbrk.tri share/libthai/thbrk.tri
				   DEPENDS data/thbrk.tri)
add_custom_target(TRI ALL DEPENDS share/libthai/thbrk.tri)
install(FILES share/libthai/thbrk.tri DESTINATION share/libthai)

# For pkgconfig
# We follow debian convention i.e. pkgconfig directory is sibbling to lib, dir and include directories
set(prefix      "\${pcfiledir}/../..")
set(exec_prefix "\${prefix}")
set(libdir      "\${exec_prefix}/lib")
set(includedir  "\${prefix}/include")
set(VERSION     ${PROJECT_VERSION})
# freebidi.pc assumes that compiler/linker uses -L, -l and -I.
# Make sure we replace them by current settings
CONFIGURE_FILE("libthai.pc.in" "libthai.pc" @ONLY)
install(FILES libthai.pc DESTINATION lib/pkgconfig)

# Tests
enable_testing()
Include(FindIconv)
if(NOT ICONV_FOUND)
  message(FATAL_ERROR "Iconv not found")
endif()
message(STATUS: "Iconv_INCLUDE_DIRS: ${Iconv_INCLUDE_DIRS}")
message(STATUS: "Iconv_LIBRARIES   : ${Iconv_LIBRARIES}")
message(STATUS: "Iconv_VERSION     : ${Iconv_VERSION}")
message(STATUS: "Iconv_INCLUDE_DIR : ${Iconv_INCLUDE_DIR}")
message(STATUS: "Iconv_LIBRARY     : ${Iconv_LIBRARY}")
#
# thsort is different
#
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/bindiff.pl [=[#!env perl
use strict;
use diagnostics;

my ($a, $b) = @ARGV;

print "Binary comparison of $a and $b\n";

open(A, '<', $a) || die "Cannot open $a, $!";
binmode A;
my $ca = do { local $/; <A> };
close(A) || warn "Cannot close $a, $!";

open(B, '<', $b) || die "Cannot open $b, $!";
binmode B;
my $cb = do { local $/; <B> };
close(B) || warn "Cannot close $b, $!";

exit($a cmp $b ? 0 : 1);
]=])

foreach(_testsrc test_thctype test_thcell test_thinp test_thrend test_thstr thsort test_thbrk test_thwchar test_thwbrk)
  add_executable(${_testsrc} tests/${_testsrc}.c)
  add_dependencies(${_testsrc} TRI)
  target_compile_definitions(${_testsrc} PRIVATE -D_CRT_SECURE_NO_WARNINGS)
  target_include_directories(${_testsrc} PRIVATE include ${Iconv_INCLUDE_DIRS})
  target_link_directories(${_testsrc} PRIVATE ${DATRIE_LIBRARY_DIRS})
  target_link_libraries(${_testsrc} thai ${Iconv_LIBRARIES} ${DATRIE_LIBRARIES})
  #
  # thsort test is different, we split it to twos:
  # 1. Call of thsort itself
  # 2. Binary comparison of tshort output with expected output
  #
  if(${_testsrc} STREQUAL "thsort")
    add_test(NAME do_${_testsrc}        COMMAND $<TARGET_FILE:${_testsrc}>                     tests/sorttest.txt ${CMAKE_CURRENT_BINARY_DIR}/out.txt)
    add_test(NAME do_${_testsrc}_verify COMMAND ${PERL} ${CMAKE_CURRENT_BINARY_DIR}/bindiff.pl tests/sorttest.txt ${CMAKE_CURRENT_BINARY_DIR}/out.txt)
	set_tests_properties(do_${_testsrc}_verify PROPERTIES DEPENDS do_${_testsrc})
  else()
    add_test(NAME do_${_testsrc} COMMAND ${_testsrc})
  endif()
endforeach()
