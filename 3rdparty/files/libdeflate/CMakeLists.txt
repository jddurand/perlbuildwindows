cmake_minimum_required(VERSION 3.12)

project(libdeflate VERSION 1.14)

add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS -DLIBDEFLATE_DLL)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

string(REGEX REPLACE "^([0-9]+\\.[0-9]+\\.[0-9]+)$" "\\1"     VERSION       ${PROJECT_VERSION})
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1" MAJOR_VERSION ${PROJECT_VERSION})
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\2" MINOR_VERSION ${PROJECT_VERSION})

add_library(libdeflate SHARED
      lib/adler32.c
	  lib/crc32.c
	  lib/deflate_compress.c
	  lib/deflate_decompress.c
	  lib/gzip_compress.c
	  lib/gzip_decompress.c
	  lib/utils.c
	  lib/x86/cpu_features.c
	  lib/zlib_compress.c
	  lib/zlib_decompress.c)

add_executable(gzip programs/gzip.c programs/prog_util.c programs/tgetopt.c)
add_executable(gunzip programs/gzip.c programs/prog_util.c programs/tgetopt.c)

target_link_libraries(gzip PUBLIC libdeflate)
target_link_libraries(gunzip PUBLIC libdeflate)

target_include_directories(gzip PRIVATE programs)
target_include_directories(gunzip PRIVATE programs)

set_target_properties(libdeflate
    PROPERTIES
    VERSION       "${VERSION}"
    SOVERSION     "${MAJOR_VERSION}"
	PUBLIC_HEADER libdeflate.h
    )

install(TARGETS libdeflate gzip gunzip PUBLIC_HEADER DESTINATION include)

# For pkgconfig
# We follow debian convention i.e. pkgconfig directory is sibbling to lib, dir and include directories
set(PREFIX      "\${pcfiledir}/../..")
set(exec_prefix "\${prefix}")
set(LIBDIR      "\${exec_prefix}/lib")
set(INCDIR      "\${prefix}/include")
CONFIGURE_FILE(libdeflate.pc.in libdeflate.pc @ONLY)
install(FILES libdeflate.pc DESTINATION lib/pkgconfig)
