cmake_minimum_required(VERSION 3.12)

project(libXpm VERSION 3.5.11 LANGUAGES C)

add_library(Xpm SHARED
	src/Attrib.c
	src/CrBufFrI.c
	# src/CrBufFrP.c # Pixmap off for MSW
	src/CrDatFrI.c
	# src/CrDatFrP.c # Pixmap off for MSW
	src/CrIFrBuf.c
	src/CrIFrDat.c
	# src/CrIFrP.c # Pixmap off for MSW
	# src/CrPFrBuf.c # Pixmap off for MSW
	# src/CrPFrDat.c # Pixmap off for MSW
	# src/CrPFrI.c # Pixmap off for MSW
	src/Image.c
	src/Info.c
	src/RdFToBuf.c
	src/RdFToDat.c
	src/RdFToI.c
	# src/RdFToP.c # Pixmap off for MSW
	src/WrFFrBuf.c
	src/WrFFrDat.c
	src/WrFFrI.c
	# src/WrFFrP.c # Pixmap off for MSW
	src/XpmI.h
	src/create.c
	src/data.c
	src/hashtab.c
	src/misc.c
	src/parse.c
	src/rgb.c
	src/rgbtab.h
	src/scan.c
	# src/amigax.c # Amiga only
	# src/amigax.h # Amiga only
	src/simx.c
	src/simx.h
	Xpm.def
	)

target_compile_definitions(Xpm PRIVATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE -DFOR_MSW)
target_include_directories(Xpm PUBLIC include/X11)

set(public_headers
	include/X11/xpm.h
	src/simx.h
)

set_target_properties(Xpm
    PROPERTIES
    VERSION       "${XPM_MAJOR_VERSION}.${XPM_MINOR_VERSION}.${XPM_MICRO_VERSION}"
    SOVERSION     "${XPM_MAJOR_VERSION}"
	PUBLIC_HEADER "${public_headers}"
    )
install(TARGETS Xpm)


# For pkgconfig
# We follow debian convention i.e. pkgconfig directory is sibbling to lib, dir and include directories
set(prefix          "\${pcfiledir}/../..")
set(exec_prefix     "\${prefix}")
set(libdir          "\${exec_prefix}/lib")
set(includedir      "\${prefix}/include")
set(PACKAGE_VERSION ${PROJECT_VERSION})
# freebidi.pc assumes that compiler/linker uses -L, -l and -I.
# Make sure we replace them by current settings
CONFIGURE_FILE("xpm.pc.in" "xpm.pc" @ONLY)
install(FILES xpm.pc DESTINATION lib/pkgconfig)
