cmake_minimum_required(VERSION 3.0.0)

# detect version
file (READ configure.ac configure_ac)
string (REGEX REPLACE ".*pixman_major], ([0-9]+).*" "\\1" PIXMAN_VERSION_MAJOR ${configure_ac})
string (REGEX REPLACE ".*pixman_minor], ([0-9]+).*" "\\1" PIXMAN_VERSION_MINOR ${configure_ac})
string (REGEX REPLACE ".*pixman_micro], ([0-9]+).*" "\\1" PIXMAN_VERSION_MICRO ${configure_ac})

project(pixman VERSION "${PIXMAN_VERSION_MAJOR}.${PIXMAN_VERSION_MINOR}.${PIXMAN_VERSION_MICRO}")

# Dependencies
find_package(Threads)
find_package(PNG)
find_package(OpenMP)

# Arch optimizations
include(${CMAKE_SOURCE_DIR}/cmake/arch_detect.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/arch_configure.cmake)

# Config
include(${CMAKE_SOURCE_DIR}/cmake/config_configure.cmake)

include_directories(
    ${CMAKE_BINARY_DIR}/pixman
    ${CMAKE_SOURCE_DIR}/pixman
)

add_subdirectory(pixman)
add_subdirectory(test)

include(${CMAKE_SOURCE_DIR}/cmake/cmake_package.cmake)
