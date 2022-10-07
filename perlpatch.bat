REM
REM We patch only the Makefile
REM %1: ${REPLACE_VBS_DOS}
REM %2: ${PERL_SOURCE_DIR_DOS}
REM %3: ${PERL_CCTYPE}
REM %4: ${PERL_WIN64}
REM %5: ${PERL_INSTSUBDIR}
REM %6: ${PERL_INSTDRV}

REM Change PERL_CCTYPE
cscript "%1" "%2\win32\Makefile" "#\s*CCTYPE\s*=\s*%3" "CCTYPE = %3"

REM Change WIN64
cscript "%1" "%2\win32\Makefile" "#\s*WIN64" "%4"

REM Change Installation to a directory that contains the compiler used, the version and the architecture.
REM No need to play with INST_VER or INST_ARCH
cscript "%1" "%2\win32\Makefile" "INST_DRV\s*=\s*c:" "INST_DRV	= %6"
cscript "%1" "%2\win32\Makefile" "INST_TOP\s*=\s*\$\(INST_DRV\)\\perl" "INST_TOP	= $(INST_DRV)\%5"
REM cscript "%1" "%2\win32\Makefile" "#\s*INST_VER" "INST_VER"
REM cscript "%1" "%2\win32\Makefile" "#\s*INST_ARCH" "INST_ARCH"
REM cscript "%1" "%2\win32\Makefile" "#\s*USE_SITECUST" "USE_SITECUST"
