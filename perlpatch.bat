REM
REM We patch only the Makefile
REM %1: ${REPLACE_VBS_DOS}
REM %2: ${PERL_CCTYPE}
REM %3: ${PERL_WIN64}
REM %4: ${PERL_INSTSUBDIR}
REM %5: ${PERL_INSTDRV}

REM Change PERL_CCTYPE
cscript "%1" "win32\Makefile" "#\s*CCTYPE\s*=\s*%2" "CCTYPE = %2"

REM Change WIN64
cscript "%1" "win32\Makefile" "#\s*WIN64" "%3"

REM Change Installation to a directory that contains the compiler used, the version and the architecture.
REM No need to play with INST_VER or INST_ARCH
cscript "%1" "win32\Makefile" "INST_DRV\s*=\s*c:" "INST_DRV	= %5"
cscript "%1" "win32\Makefile" "INST_TOP\s*=\s*\$\(INST_DRV\)\\perl" "INST_TOP	= $(INST_DRV)\%4"
REM cscript "%1" "win32\Makefile" "#\s*INST_VER" "INST_VER"
REM cscript "%1" "win32\Makefile" "#\s*INST_ARCH" "INST_ARCH"
REM
REM We enable the support of $Config{sitelibexp}\sitecustomize.pl
REM
cscript "%1" "win32\Makefile" "#\s*USE_SITECUST" "USE_SITECUST"
REM
REM We enable CFG=Debug
REM
REM cscript "%1" "win32\Makefile" "#\s*CFG\s*=\s*Debug" "CFG		= Debug"
