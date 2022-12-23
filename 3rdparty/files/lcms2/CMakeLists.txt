cmake_minimum_required(VERSION 3.6)
project(lcms2 VERSION 2.14 LANGUAGES C)
include(TestBigEndian)
include(CheckCSourceCompiles)
include(FindThreads)
include(CheckTypeSize)

test_big_endian(IS_BIG_ENDIAN)
if(IS_BIG_ENDIAN)
	add_definitions(-DWORDS_BIGENDIAN)
endif()

check_c_source_compiles([[
#include <time.h>
int main(int argc, char** argv)
{
	time_t t;
	struct tm m;
	gmtime_s(&m, &t);
	return 0;
}
]] HAVE_GMTIME_S
)

check_c_source_compiles([[
#include <emmintrin.h>
int main() {
  __m128i n = _mm_set1_epi8(42);
}
]] HAVE_SSE2_INTRINSICS
)
if(NOT HAVE_SSE2_INTRINSICS)
	add_definitions(-DCMS_DONT_USE_SSE2)
endif()

CHECK_TYPE_SIZE("long long" LONG_LONG)
if (NOT HAVE_LONG_LONG)
	add_definitions(-DCMS_DONT_USE_INT64)
endif()

if(UNIX)
	set(LIB_MATH -lm)
else()
	set(LIB_MATH)
endif()
set(prefix      "\${pcfiledir}/../..")
set(exec_prefix "\${prefix}")
set(libdir      "\${exec_prefix}/lib")
set(includedir  "\${prefix}/include")
set(PACKAGE     "lcms2")
set(LIB_THREAD  ${CMAKE_THREAD_LIBS_INIT})
set(VERSION     ${PROJECT_VERSION})
configure_file(lcms2.pc.in lcms2.pc @ONLY)
install(FILES lcms2.pc DESTINATION lib/pkgconfig)

include_directories("include")

file(GLOB SRC_FILES src/*.c)
set(public_headers include/lcms2.h include/lcms2_plugin.h)
add_library(lcms2 SHARED ${SRC_FILES} src/lcms2.def)
set_target_properties(lcms2
    PROPERTIES
    VERSION       "${VERSION}"
    SOVERSION     "${MAJOR_VERSION}"
	PUBLIC_HEADER "${public_headers}"
)
target_link_libraries(lcms2 PRIVATE
	${LIB_MATH}
	${LIB_THREAD}
)

install(TARGETS lcms2
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
