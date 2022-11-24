cmake_minimum_required(VERSION 3.12)

project(gdiplus VERSION 0.0.0)

add_library(gdiplus INTERFACE)
target_include_directories(gdiplus INTERFACE 
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/gdiplus>
    $<INSTALL_INTERFACE:include>
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${PROJECT_BINARY_DIR}/gdiplusConfigVersion.cmake"
    COMPATIBILITY AnyNewerVersion
)

install(TARGETS gdiplus
    EXPORT gdiplusTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include
    BUNDLE DESTINATION bin
)

install(EXPORT gdiplusTargets DESTINATION lib/cmake/gdiplus)
install(FILES "${PROJECT_BINARY_DIR}/gdiplusConfigVersion.cmake"
        DESTINATION lib/cmake/gdiplus)
install(DIRECTORY ${PROJECT_SOURCE_DIR}/include/gdiplus DESTINATION include)
