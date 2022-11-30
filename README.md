# Perl build on Windows

This is a CMake script that will compile Perl on Windows using Microsoft Visual Studio `cl`. A big package is finally created.

_Everything_ is compiled from scratch.

## Main changes with main stream packages

* Win32::GUI is patched to work with latest freeimage
* tiff is patched to compile with freeglut

## Current perl version and external projects

Copied verbatim from the generation of Makefile:

```
-- ===================================
-- Version of Perl                   : 5.37.6
-- ===================================
--
-- ===================================
-- Perl packages forced versions
-- ===================================
-- Version of Net::SSLeay            : 1.93_01
-- Version of Win32::GUI             : 1.14
--
-- ===================================
-- External packages
-- ===================================
-- Version of nasm                   : 2.15.05
-- Version of openssl                : 3.0.5
-- Version of zlib                   : 1.2.13
-- Version of expat                  : 2.5.0
-- Version of fribidi                : 1.0.12
-- Version of giflib                 : 5.2.1
-- Version of freeimage              : 3.18.0
-- Version of thai                   : 0.1.29
-- Version of datrie                 : 0.2.13
-- Version of libiconv               : 1.17
-- Version of libheif                : 1.13.0
-- Version of libde265               : 1.0.9
-- Version of SDL2                   : 2.26.0
-- Version of sdl2-compat            : 1.2.60
-- Version of x265                   : 3.4
-- Version of aom                    : 3.5.0
-- Version of libjpeg-turbo          : 2.1.4
-- Version of libpng                 : 1.6.39
-- Version of tiff                   : 4.4.0
-- Version of libdeflate             : 1.14
-- Version of jbigkit                : 2.1
-- Version of lerc                   : 4.0.0
-- Version of xz                     : 5.2.8
-- Version of zstd                   : 1.5.2
-- Version of libwebp                : 1.2.4
-- Version of gdiplus                : prima
-- Version of libXpm                 : 3.5.14
-- Version of freeglut               : 3.4.0
-- ===================================
```

# Do it yourself

## Prerequisites

You will need the `cl` compile, CMake and a working `patch` executable:

* If not already available, install Visual Studio c.f. https://visualstudio.microsoft.com/fr/vs/community/
* If not already available (it is bundled with recent Visual Studio, e.g. 2022), download it at https://cmake.org/download/
* The easiest, and what is supported by default, is to install Git For Windows at https://gitforwindows.org/

## Preparing a build directory

CMake is used as a _facility_ here, not to have a portable build, and the _only_ build type supported is "NMake Makefiles". To proceed:

* Clone this repository
	* It is important to keep line-endings in the UNIX style
* Create a working directory
* Initiate a Windows Makefile 
* Build all
	* This will install in C:\cl-perl-VERSION-XXbit
* Build the package

```
git clone git@github.com:jddurand/perlbuildwindows.git --config core.autocrlf=false
mkdir perlbuildwindows-build
cd perlbuildwindows-build
cmake -G "NMake Makefiles" ..\perlbuildwindows
nmake
nmake package
```
