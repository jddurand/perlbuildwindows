# Perl build on Windows

This is a CMake script that will compile Perl on Windows using Microsoft Visual Studio `cl`. A big package is finally created.

_Everything_ is compiled from scratch.

## Why ?

Every software gains in robustness if it can compile and work natively on different platforms. So a _pure_ Windows version of Perl can only benefit to the later.

In general, as a software developer, I personnally _want_ to have all my dependencies built using the _same_ compiler that I use to develop my personal projects, whatever it is:
* gcc
* clang
* CC (Sun/Solaris)
* xlc (AIX)
* cl/bcc
* etc...

Back to Windows case, I use cl. So I want _everything_ to be cl based. Full point.

Back to Perl case:
* Strawberry Perl distribution switched to gcc toolchain few years ago, so I abandonned it. This is not a critiscm, Strawberry Perl is just awesome. But does not fit my technical prerequesites.
* ActiveState perl have a pure cl version as far as I understood, never tried, you might, well I'd recommend, want to use it instead
* I do not know if there are other _cl_ based Perl distributions

Finally this project is for my personal fun, I like the idea to be able to help Perl language robustness and portability by doing this exercise.

## A little FAQ

I would have in mind only few questions that would knock in my head if I would install perl from this page:

* What architecture ?

Currently only x86.

* It proposes to install to C:\cl-perl-VERSION-ARCHbits - may I use another installation directory ?

I've done the best as I can to make it relocatable, using what perl is calling "sitecustomize.pl" (c.f. https://perldoc.perl.org/perlrun). This is experimental and sensible code, though it seems to work fine for me.

* What if something is not working for me ?

Well, you can open an issue on this github project, I'll be glad to help/try to understand. All in all if this can improve this personal project or Perl, that's good.

## The most important things to know about this package

* Win32::GUI is patched to work with latest freeimage
* Also experimental, perl executable in this package is aimed to be relocatable
* Relocatable pkgconfig files as well, with a "perl" version of pkgconfig that is taking precedence in %PATH%

## Current Perl and external projects versions

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

What I mean by forced versions for some Perl packages, is that I did patch them is a sensible way, so that IMHO only these versions are guaranteed to be ok. So I force them in the script.

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

Some words on testing before installing:
* Perl tests must be ok
* openssl tests must be ok
* External projects tests are executed if available
	* Some external projects have know defects and known fixes, or I simply had to patch them to have installation paths that fit my installation tree, c.f. the 3rdpaty/patches directory in this project
* Perl packages tests via CPAN must be ok (there is no "force install" anywhere in my script)
	* Some CPAN packages have know defects and know fixes, c.f. the patches directory in this project
