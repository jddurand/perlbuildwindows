REM
REM We patch only the Makefile
REM %1: ${PROJECT_SOURCE_DIR}
REM %2: ${PROJECT_SOURCE_DIR}/${PERL_SOURCE_DIR}
REM %3: ${CCTYPE}
REM %4: ${PERL_WIN64}

REM CCTYPE
cscript "%1\replace.vbs" "%2\win32\Makefile" "#\s*CCTYPE\s*=\s*%3" "CCTYPE = %3"

REM WIN64
cscript "%1\replace.vbs" "%2\win32\Makefile" "#\s*WIN64" "%4"

REM Installation
REM cscript "%1\replace.vbs" "%2\win32\Makefile" "INST_TOP\s*=\s*\$\(INST_DRV\)\\perl" "INST_TOP	= $(INST_DRV)\perl"
cscript "%1\replace.vbs" "%2\win32\Makefile" "#\s*INST_VER" "INST_VER"
cscript "%1\replace.vbs" "%2\win32\Makefile" "#\s*INST_ARCH" "INST_ARCH"
cscript "%1\replace.vbs" "%2\win32\Makefile" "#\s*USE_SITECUST" "USE_SITECUST"
