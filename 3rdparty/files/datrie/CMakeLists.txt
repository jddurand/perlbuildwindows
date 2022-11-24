cmake_minimum_required(VERSION 3.12)

project(datrie VERSION 0.2.16)

add_definitions(-D_CRT_SECURE_NO_WARNINGS)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

#
# We will depend on iconv distributed with localcharset.h
#
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/config.h "
#ifndef DATRIE_CONFIG_H
#define DATRIE_CONFIG_H
#define HAVE_LOCALE_CHARSET
#endif /* DATRIE_CONFIG_H */
")

string(REGEX REPLACE "^([0-9]+\\.[0-9]+\\.[0-9]+)$" "\\1"     VERSION       ${PROJECT_VERSION})
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1" MAJOR_VERSION ${PROJECT_VERSION})
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\2" MINOR_VERSION ${PROJECT_VERSION})
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\3" PATCH_VERSION ${PROJECT_VERSION})


add_library(datrie SHARED
	datrie/dstring.c
	datrie/trie-string.c
	datrie/fileutils.c
	datrie/darray.c
	datrie/tail.c
	datrie/trie.c
	datrie/alpha-map.c
	)
target_compile_definitions(datrie PRIVATE -DLIBDATRIE_BUILD)

set(public_headers
    datrie/alpha-map.h
    datrie/trie.h
    datrie/triedefs.h
    datrie/typedefs.h)

set_target_properties(datrie
    PROPERTIES
    VERSION       "${VERSION}"
    SOVERSION     "${MAJOR_VERSION}"
	PUBLIC_HEADER "${public_headers}"
    )

add_executable(trietool tools/trietool.c)
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
# Specific for libcharset - copied from https://github.com/InsightSoftwareConsortium/DCMTK/blob/master/CMake/FindLIBCHARSET.cmake
#
include(FindPackageHandleStandardArgs)
find_path(LIBCHARSET_INCLUDE_DIR NAMES localcharset.h)
mark_as_advanced(LIBCHARSET_INCLUDE_DIR)
set(LIBCHARSET_LIBS libcharset)
find_library(LIBCHARSET_LIBRARY NAMES ${LIBCHARSET_LIBS})
mark_as_advanced(LIBCHARSET_LIBRARY)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LIBCHARSET REQUIRED_VARS LIBCHARSET_LIBRARY LIBCHARSET_INCLUDE_DIR)
if(NOT LIBCHARSET_FOUND)
  message(FATAL_ERROR "Libcharset not found")
endif()
set(LIBCHARSET_INCLUDE_DIRS ${LIBCHARSET_INCLUDE_DIR})
set(LIBCHARSET_LIBRARIES ${LIBCHARSET_LIBRARY})
message(STATUS: "LIBCHARSET_INCLUDE_DIRS: ${LIBCHARSET_INCLUDE_DIRS}")
message(STATUS: "LIBCHARSET_LIBRARIES   : ${LIBCHARSET_LIBRARIES}")

target_include_directories(trietool PRIVATE ${Iconv_INCLUDE_DIRS} ${LIBCHARSET_INCLUDE_DIRS})
target_link_libraries(trietool PUBLIC datrie ${Iconv_LIBRARIES} ${LIBCHARSET_LIBRARIES})
target_compile_definitions(trietool PRIVATE -DVERSION="${VERSION}")
install(TARGETS datrie trietool PUBLIC_HEADER DESTINATION include/datrie)

# For pkgconfig
# We follow debian convention i.e. pkgconfig directory is sibbling to lib, dir and include directories
set(prefix      "\${pcfiledir}/../..")
set(exec_prefix "\${prefix}")
set(libdir      "\${exec_prefix}/lib")
set(includedir  "\${prefix}/include")
CONFIGURE_FILE("datrie-${MAJOR_VERSION}.${MINOR_VERSION}.pc.in" "datrie-${MAJOR_VERSION}.${MINOR_VERSION}.pc" @ONLY)
install(FILES "datrie-${MAJOR_VERSION}.${MINOR_VERSION}.pc" DESTINATION lib/pkgconfig)
