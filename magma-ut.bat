::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  Magma-UT
::  Copyright (C) 2020 Ulrich Thiel
::  Licensed under GNU GPLv3, see License.md
::  https://github.com/ulthiel/magma-ut
::  thiel@mathematik.uni-kl.de, https://ulthiel.com/math
::
::  Start Magma-UT (and automatically set the necessary environment variables)
::
::  Please be amazed by my Windows batch skills, just acquired for this project!
::  I thought the bash is absurd sometimes, but now I know better.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: clear screen
::cls

:: prevent output
@echo off

:: otherwise variables will exist globally
setlocal

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set up all the environment variables for Magma-UT
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: current directory. in contrast to the unix version this comes with a
:: trailing backslash. i therefore add dot at the end.
set MAGMA_UT_BASE_DIR=%~dp0.

:: no quotation marks here
set MAGMA_UT_OS_TYPE=Windows

:: the value of %OS% is Windows_NT since Windows XP i think.
:: uname.exe -s outputs WindowsNT and I'll just go for this.
:: i don't care about any older Windows any more but i think this will also not
:: get relevant.
set MAGMA_UT_OS=WindowsNT

:: first, check if there's Config\Config.txt.
:: if not, copy over Config_org.txt
if not exist "%MAGMA_UT_BASE_DIR%\Config\Config.txt" (
  copy "%MAGMA_UT_BASE_DIR%\Config\Config_org.txt" "%MAGMA_UT_BASE_DIR%\Config\Config.txt" >NUL
)

:: now, source the config file.
:: first, we need to replace $VAR by %VAR%
:: do this with sed, temporarily creating Config\Config_win.txt
"%MAGMA_UT_BASE_DIR%\Tools\UnixTools\sed.exe" -e s/\$\([a-zA-Z0-9_]\+\)/%%\1%%/g "%MAGMA_UT_BASE_DIR%\Config\Config.txt" > "%MAGMA_UT_BASE_DIR%\Config\Config_win.txt"

:: now, parse.
:: the following code ignores the hash for comments, this is quite neat
for /f "eol=# delims=" %%i in ('type "%MAGMA_UT_BASE_DIR%\Config\Config_win.txt"') do (call set "%%i")

del "%MAGMA_UT_BASE_DIR%\Config\Config_win.txt"

:: Replace forward slash by backward slash in DB directories
if defined MAGMA_UT_DB_DIRS (
	set MAGMA_UT_DB_DIRS=%MAGMA_UT_DB_DIRS:/=\%
)

:: Replace forward slash by backward slash in Magma directory
if defined MAGMA_UT_MAGMA_DIR (
    set MAGMA_UT_MAGMA_DIR=%MAGMA_UT_MAGMA_DIR:/=\%
)

:: Replace forward slash by backward slash in package list
if defined MAGMA_UT_PKGS (
    set MAGMA_UT_PKGS=%MAGMA_UT_PKGS:/=\%
)

:: download tool will always be curl because I provide it with the package.
set MAGMA_UT_DWN_TOOL=curl

:: Get the OS version (more detailed than MAGMA_UT_OS)
for /f "delims== tokens=2-3" %%f in ('wmic os get Version /value ^| find "="') do (
    set MAGMA_UT_OS_VER=Microsoft Windows %%f
)

:: Hostname
for /F "tokens=* USEBACKQ" %%F in (`hostname`) do (
    set MAGMA_UT_HOSTNAME=%%F
)

:: CPU
for /f "delims== tokens=2-3" %%f in ('wmic cpu get Name /value ^| find "="') do (
    set MAGMA_UT_CPU=%%f
)

:: Architecture
for /f "delims== tokens=2-3" %%f in ('wmic os get OSArchitecture /value ^| find "="') do (
    set MAGMA_UT_OS_ARCH=%%f
)

:: Memory
for /f "delims== tokens=2-3" %%f in ('wmic ComputerSystem get TotalPhysicalMemory /value ^| find "="') do (
    set MAGMA_UT_TOTAL_MEM=%%f
)



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Find Magma (first user defined path, then environment path, then trying
:: some directories, then give up).
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::first, use path provided by user
if defined MAGMA_UT_MAGMA_DIR (
    if exist "%MAGMA_UT_MAGMA_DIR%\magma.exe" (
      set MAGMA_EXEC="%MAGMA_UT_MAGMA_DIR%\magma.exe"
      goto startmagma
    )
)

::now, check if magma is in path
where magma >NUL 2>&1
if %ERRORLEVEL% equ 0 (
    set MAGMA_EXEC="magma"
    goto startmagma
)

::now, check the program files paths
if exist "%ProgramFiles%\Magma\magma.exe" (
    set MAGMA_EXEC="%ProgramFiles%\Magma\magma.exe"
    goto startmagma
)

if exist "%ProgramFiles(x86)%\Magma\magma.exe" (
    set MAGMA_EXEC="%ProgramFiles(x86)%\Magma\magma.exe"
    goto startmagma
)

if exist "%ProgramW6432%\Magma\magma.exe" (
    set MAGMA_EXEC="%ProgramW6432%\Magma\magma.exe"
    goto startmagma
)

::at last, try to read Magma installation directory from registry
::(i'm not sure if this is always the correct key though)
setlocal ENABLEEXTENSIONS
set KEY_NAME="HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Magma_is1"
set VALUE_NAME=InstallLocation

for /F "usebackq skip=2 tokens=2,*" %%A in (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO (
    set MAGMA_UT_MAGMA_DIR="%%B"
)

if defined MAGMA_UT_MAGMA_DIR (
	if exist "%MAGMA_UT_MAGMA_DIR%magma.exe" (
	    set MAGMA_EXEC="%MAGMA_UT_MAGMA_DIR%magma.exe"
	    goto startmagma
	)

)

:nomagma
echo Error: cannot find Magma.
echo Either add Magma installation directory to Config.txt or to PATH environment variable.
pause
exit /b

:: From here on, everything is fine
:startmagma

:: add the MAGMA_UT spec file to the Magma startup spec variable
set MAGMA_USER_SPEC=%MAGMA_UT_BASE_DIR%\Packages\Magma-UT\Magma-UT.s.m;%MAGMA_USER_SPEC%

::Set the MAGMA_UT startup file as Magma startup file
set MAGMA_STARTUP_FILE=%MAGMA_UT_BASE_DIR%\Packages\Magma-UT\Startup.m

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Now, start Magma with the Startup script from the Config directory
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%MAGMA_EXEC% -b %*
