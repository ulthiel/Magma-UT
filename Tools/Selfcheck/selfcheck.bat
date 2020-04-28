::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Magma-UT
:: Copyright (C) 2020 Ulrich Thiel
:: Licensed under GNU GPLv3, see COPYING.
:: https://github.com/ulthiel/magma-ut
:: thiel@mathematik.uni-kl.de, https://ulthiel.com/math
::
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enableDelayedExpansion

:: First, make sure this script is run from the SelfCheck directory.
:: I need this to have less fiddling below.
if not exist ..\..\magma-ut (
  echo Error: you need to run this script directly from the SelfCheck directory.
  exit /b 1
)

:: Parse arguments
set REPORT=0
set selfcheckCount=0
:argloop
if not "%1"=="" (
  if "%1"=="-p" (
    set PACKAGE=%2
    shift
  ) else if "%1"=="-r" (
    set REPORT=1
  ) else (
    set /A selfcheckCount+=1
    set "SELFCHECKS[!selfcheckCount!]=%1"
  )
  shift
  goto :argloop
)

:: Check if package specified
if not defined PACKAGE (
  echo Please specify package to selfcheck with -p option.
  pause
  exit /b
)

:: If no files given, then just take all selfchecks
if "%selfcheckCount%"=="0" (
  cd ..\..\Packages\%PACKAGE%\Selfchecks\
  ::for %%x in (*.m) do (
  for /f "tokens=*" %%x in ('dir /b *.m ^| sort') do (
    set /A selfcheckCount+=1
    set "SELFCHECKS[!selfcheckCount!]=%%~x"
  )
  cd ..\..\..\Tools\Selfcheck
)

:: Gather some system information for reporting
if "%REPORT%"=="1" (

  :: Hostname
  FOR /F "tokens=* USEBACKQ" %%F IN (`hostname`) DO (
    SET HOST=%%F
  )

  :: OS version
  for /f "delims== tokens=2-3" %%f in ('wmic os get Version /value ^| find "="') do (
    set OS_VER=Microsoft Windows %%f
  )

  :: CPU
  for /f "delims== tokens=2-3" %%f in ('wmic cpu get Name /value ^| find "="') do (
    set CPU=%%f
  )

  :: CHAMP version
  git describe >NUL 2>NUL
  if %ERRORLEVEL% equ 0 (
    FOR /F "tokens=* USEBACKQ" %%F IN (`git describe`) DO (
      SET CHAMP_VER=%%F
    )
  ) else (
    if exist "..\..\version.txt" (
      set /p CHAMP_VER= < ..\..\version.txt
    )
  )
)

:: Create Log directory
..\UnixTools\mkdir.exe -p Log/%PACKAGE%

:: Tab character for printing
SET "TAB=	"

:: Now, go through the selfchecks
for /L %%i in (1,1,%selfcheckCount%) do (

  rem Getting test test name. For fucks sake!
  set SELFCHECK=!SELFCHECKS[%%i]!

  rem Remove the current path from the folder name
  for %%A in ("!SELFCHECK!") do (
    Set Folder=%%~dpA
    Set Name0=%%~nA
  )
  set NAME=!Folder:%~dp0=!!Name0!

  echo | set /p=!NAME!

  rem Get date in correct format
  FOR /F "tokens=* USEBACKQ" %%F IN (`..\UnixTools\date.exe -u +"%%Y-%%m-%%d %%H:%%M:%%S"`) DO (
    SET SELFCHECK_DATE=%%F
  )

  rem Create lock file
  type NUL > Log\%PACKAGE%\!Name!.lck

  rem This is the initial Magma code to start and report the selfcheck
  set INIT=SetAssertions(1^); ^
SetQuitOnError(true^); ^
AttachSpec("..\\..\\Packages\\%PACKAGE%\\%PACKAGE%.s.m"^); ^
printf "MAGMA_UT_SELFCHECK_MAGMA=%%o\n", GetVersionString(^); ^
MAGMA_UT_SELFCHECK_TIME := Cputime(^); ^
assert FileExists("..\\..\\Packages\\%PACKAGE%\\Selfchecks\\!NAME!.m"^); ^
load "..\\..\\Packages\\%PACKAGE%\\Selfchecks\\!NAME!.m"; ^
printf "MAGMA_UT_SELFCHECK_TIME=%%o\n", Cputime(MAGMA_UT_SELFCHECK_TIME^); ^
printf "MAGMA_UT_SELFCHECK_MEM=%%o\n", Round(GetMemoryUsage(^)/1000000^); ^
DeleteFile("Log\\%PACKAGE%\\!NAME!.lck"^); ^
quit;

  del Log\%PACKAGE%\!NAME!.log >NUL 2>NUL

  rem Start Magma with the the initial code and write both stdout and stderr
  rem to the log file.
  rem I have no idea why I need to do a "call" here but otherwise
  rem it stops here at an error.
  echo !INIT! | call ..\..\magma-ut.bat >Log\%PACKAGE%\!NAME!.log 2>&1

  set RES1=!ERRORLEVEL!

  rem Search for "error" keyword in the logfile.
  rem If not found, grep exits with error level 1.
  ..\UnixTools\grep.exe -i "error" "Log\%PACKAGE%\!NAME!.log" >NUL 2>&1

  set RES2=!ERRORLEVEL!

  set RESULT=0

  if exist Log\%PACKAGE%\!NAME!.lck (
    set RESULT=1
  )
  if "!RES1!"=="1" (
    set RESULT=1
  )
  if "!RES2!"=="0" (
    set RESULT=1
  )

  if "!RESULT!"=="1" (
    echo.!TAB![91m FAILED [0m
  ) else (

    rem Get time, bloody hell!
    FOR /F "tokens=* USEBACKQ" %%F IN (`..\UnixTools\grep.exe "MAGMA_UT_SELFCHECK_TIME" "Log\%PACKAGE%\!NAME!.log"`) DO (
      SET OUTPUT=%%F
    )

    for /F "tokens=1,2 delims=^=" %%a in ("!OUTPUT!") do (
    SET MAGMA_UT_TIME=%%b
    )

    rem Get memory
    FOR /F "tokens=* USEBACKQ" %%F IN (`..\UnixTools\grep.exe "MAGMA_UT_SELFCHECK_MEM" "Log\%PACKAGE%\!NAME!.log"`) DO (
      SET OUTPUT=%%F
    )

    for /F "tokens=1,2 delims=^=" %%a in ("!OUTPUT!") do (
    SET MAGMA_UT_MEM=%%b
    )

    echo.!TAB![32m OK [0m!TAB!!MAGMA_UT_TIME!s!TAB!!MAGMA_UT_MEM!MB
  )

  rem Get Magma version
  FOR /F "tokens=* USEBACKQ" %%F IN (`..\UnixTools\grep.exe "MAGMA_UT_SELFCHECK_MAGMA" "Log\%PACKAGE%\!NAME!.log"`) DO (
    SET OUTPUT=%%F
  )

  for /F "tokens=1,2 delims=^=" %%a in ("!OUTPUT!") do (
    SET MAGMA_VER=%%b
  )

  rem Report result
  if "!REPORT!"=="1" (
    if "!RESULT!"=="0" (
      set URL="https://ulthiel.com/champ/selfcheck-commit.php?Date=!SELFCHECK_DATE!&Test=!NAME!&Result=!RESULT!&Time=!CHAMP_TIME!&Memory=!CHAMP_MEM!&CHAMP=!CHAMP_VER!&Magma=!MAGMA_VER!&Host=!HOST!&OS=!OS_VER!&CPU=!CPU!"
    ) else (
      set URL="https://ulthiel.com/champ/selfcheck-commit.php?Date=!SELFCHECK_DATE!&Test=!NAME!&Result=!RESULT!&CHAMP=!CHAMP_VER!&Magma=!MAGMA_VER!&Host=!HOST!&OS=!OS_VER!&CPU=!CPU!"
    )

    FOR /F "tokens=* USEBACKQ" %%F IN (`echo !URL! ^| ..\UnixTools\sed.exe "s/ /%%20/g"`) DO (
      SET URL_ESC=%%F
    )

    ..\UnixTools\curl.exe !URL_ESC! >NUL 2>NUL
  )
)
