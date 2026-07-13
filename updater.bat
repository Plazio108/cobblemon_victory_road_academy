@echo off
setlocal EnableDelayedExpansion

echo ==========================
echo   Minecraft Mod Updater
echo ==========================

set "UPDATER_DIR=%~dp0"
set "ROOT=%UPDATER_DIR%.."
set "TMP=%TEMP%\MinecraftUpdater"

cd /d "%UPDATER_DIR%"


rem ==================================================
rem Self update
rem ==================================================

call "%UPDATER_DIR%lib\selfupdate.bat"

if errorlevel 2 (
    echo Starting updater replacement...

    start "" "%UPDATER_DIR%restart.bat"

    exit /b
)

if errorlevel 1 (
    echo Self update failed, continuing...
)


rem ==================================================
rem Check update file
rem ==================================================

if not exist "%UPDATER_DIR%update" (
    echo ERROR: Missing update file.
    pause
    exit /b 1
)


set "REMOTE_VERSION="
set "UPDATE_URL="
set "EXPECTED_HASH="


for /f "usebackq delims=" %%A in ("%UPDATER_DIR%update") do (
    if not defined REMOTE_VERSION (
        set "REMOTE_VERSION=%%A"
    ) else if not defined UPDATE_URL (
        set "UPDATE_URL=%%A"
    ) else (
        set "EXPECTED_HASH=%%A"
    )
)


echo.
echo Available version:
echo %REMOTE_VERSION%
echo.


rem ==================================================
rem Check installed version
rem ==================================================

set "LOCAL_VERSION=0"

if exist "%ROOT%\.installed_version" (
    set /p LOCAL_VERSION=<"%ROOT%\.installed_version"
)


if "%LOCAL_VERSION%"=="%REMOTE_VERSION%" (
    echo Already up to date.
    echo Version %LOCAL_VERSION%
    pause
    exit /b 0
)


echo Updating from %LOCAL_VERSION% to %REMOTE_VERSION%


rem ==================================================
rem Download modpack
rem ==================================================

if exist "%TMP%" (
    rd /s /q "%TMP%"
)

mkdir "%TMP%"


call "%UPDATER_DIR%lib\download.bat" ^
"%UPDATE_URL%" ^
"%TMP%\modpack.zip"


if errorlevel 1 (
    echo ERROR: Download failed.
    pause
    exit /b 1
)


rem ==================================================
rem Verify hash
rem ==================================================

call "%UPDATER_DIR%lib\verify.bat" ^
"%TMP%\modpack.zip" ^
"%EXPECTED_HASH%"


if errorlevel 1 (
    echo ERROR: File verification failed.
    pause
    exit /b 1
)


rem ==================================================
rem Install update
rem ==================================================

call "%UPDATER_DIR%lib\install.bat" ^
"%TMP%\modpack.zip"


if errorlevel 1 (
    echo ERROR: Installation failed.
    pause
    exit /b 1
)


rem ==================================================
rem Finish
rem ==================================================

echo %REMOTE_VERSION%>"%ROOT%\.installed_version"


rd /s /q "%TMP%"


echo.
echo ==========================
echo Update complete!
echo Installed version:
echo %REMOTE_VERSION%
echo ==========================

pause
exit /b 0