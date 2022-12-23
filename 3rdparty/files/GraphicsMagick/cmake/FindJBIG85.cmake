# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindJBIG85
--------

Find the native JBIG85 includes and library.

IMPORTED Targets
^^^^^^^^^^^^^^^^

This module defines :prop_tgt:`IMPORTED` target ``JBIG85::JBIG85``, if
JBIG85 has been found.

Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables:

::

  JBIG85_INCLUDE_DIRS   - where to find jbig85.h, etc.
  JBIG85_LIBRARIES      - List of libraries when using jbig85.
  JBIG85_FOUND          - True if jbig85 found.

::

  JBIG85_VERSION_STRING - The version of jbig85 found (x.y.z)
  JBIG85_VERSION_MAJOR  - The major version of jbig85
  JBIG85_VERSION_MINOR  - The minor version of jbig85

  Debug and Release variants are found separately.
#]=======================================================================]

# Standard names to search for
set(JBIG85_NAMES jbig85)
set(JBIG85_NAMES_DEBUG jbig85d)

find_path(JBIG85_INCLUDE_DIR
          NAMES jbig85.h
          PATH_SUFFIXES include)

set(JBIG85_OLD_FIND_LIBRARY_PREFIXES "${CMAKE_FIND_LIBRARY_PREFIXES}")
# Library has a "lib" prefix even on Windows.
set(CMAKE_FIND_LIBRARY_PREFIXES "lib" "")

# Allow JBIG85_LIBRARY to be set manually, as the location of the jbig85 library
if(NOT JBIG85_LIBRARY)
  find_library(JBIG85_LIBRARY_RELEASE
               NAMES ${JBIG85_NAMES}
               PATH_SUFFIXES lib)
  find_library(JBIG85_LIBRARY_DEBUG
               NAMES ${JBIG85_NAMES_DEBUG}
               PATH_SUFFIXES lib)

  include(SelectLibraryConfigurations)
  select_library_configurations(JBIG85)
endif()

set(CMAKE_FIND_LIBRARY_PREFIXES "${JBIG85_OLD_FIND_LIBRARY_PREFIXES}")

unset(JBIG85_NAMES)
unset(JBIG85_NAMES_DEBUG)
unset(JBIG85_OLD_FIND_LIBRARY_PREFIXES)

mark_as_advanced(JBIG85_INCLUDE_DIR)

if(JBIG85_INCLUDE_DIR AND EXISTS "${JBIG85_INCLUDE_DIR}/jbig85.h")
    file(STRINGS "${JBIG85_INCLUDE_DIR}/jbig85.h" JBIG85_H REGEX "^#define JBG_VERSION  *\"[^\"]*\"$")

    string(REGEX REPLACE "^.*JBG_VERSION  *\"([0-9]+).*$" "\\1" JBIG85_MAJOR_VERSION "${JBIG85_H}")
    string(REGEX REPLACE "^.*JBG_VERSION  *\"[0-9]+\\.([0-9]+).*$" "\\1" JBIG85_MINOR_VERSION  "${JBIG85_H}")
    set(JBIG85_VERSION_STRING "${JBIG85_MAJOR_VERSION}.${JBIG85_MINOR_VERSION}")

    set(JBIG85_MAJOR_VERSION "${JBIG85_VERSION_MAJOR}")
    set(JBIG85_MINOR_VERSION "${JBIG85_VERSION_MINOR}")
endif()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(JBIG85
        REQUIRED_VARS JBIG85_LIBRARY JBIG85_INCLUDE_DIR
        VERSION_VAR JBIG85_VERSION_STRING)

if(JBIG85_FOUND)
    set(JBIG85_INCLUDE_DIRS ${JBIG85_INCLUDE_DIR})

    if(NOT JBIG85_LIBRARIES)
        set(JBIG85_LIBRARIES ${JBIG85_LIBRARY})
    endif()

    if(NOT TARGET JBIG85::JBIG85)
        add_library(JBIG85::JBIG85 UNKNOWN IMPORTED)
        set_target_properties(JBIG85::JBIG85 PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${JBIG85_INCLUDE_DIRS}")

        if(JBIG85_LIBRARY_RELEASE)
            set_property(TARGET JBIG85::JBIG85 APPEND PROPERTY
                    IMPORTED_CONFIGURATIONS RELEASE)
            set_target_properties(JBIG85::JBIG85 PROPERTIES
                    IMPORTED_LOCATION_RELEASE "${JBIG85_LIBRARY_RELEASE}")
        endif()

        if(JBIG85_LIBRARY_DEBUG)
            set_property(TARGET JBIG85::JBIG85 APPEND PROPERTY
                    IMPORTED_CONFIGURATIONS DEBUG)
            set_target_properties(JBIG85::JBIG85 PROPERTIES
                    IMPORTED_LOCATION_DEBUG "${JBIG85_LIBRARY_DEBUG}")
        endif()

        if(NOT JBIG85_LIBRARY_RELEASE AND NOT JBIG85_LIBRARY_DEBUG)
            set_target_properties(JBIG85::JBIG85 PROPERTIES
                    IMPORTED_LOCATION_RELEASE "${JBIG85_LIBRARY}")
        endif()
    endif()
endif()
