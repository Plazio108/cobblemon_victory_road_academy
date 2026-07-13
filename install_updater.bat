@echo off
setlocal EnableDelayedExpansion

echo ==========================
echo Minecraft Updater Installer
echo ==========================
echo.

rem ==================================================
rem Paths
rem ==================================================

set "ROOT=%~dp0"
set "UPDATER_DIR=%ROOT%.updater"
set "TMP=%TEMP%\MinecraftUpdaterInstall"

rem ==================================================
rem Updater download URL
rem ==================================================

set "UPDATER_URL=https://github.com/Plazio108/cobblemon_victory_road_academy/releases/download/updater/updater.zip"


rem ==================================================
rem Create updater folder
rem ==================================================

echo Creating updater folder...

if not exist "%UPDATER_DIR%" (
    mkdir "%UPDATER_DIR%"
)


if exist "%TMP%" (
    rd /s /q "%TMP%"
)

mkdir "%TMP%"


rem ==================================================
rem Download updater
rem ==================================================

echo.
echo Downloading updater...

curl --ssl-no-revoke ^
     --fail ^
     --location ^
     --retry 3 ^
     --retry-delay 2 ^
     --retry-all-errors ^
     "%UPDATER_URL%" ^
     -o "%TMP%\updater.zip"


if errorlevel 1 (
    echo.
    echo ERROR: Failed downloading updater.
    pause
    exit /b 1
)


rem ==================================================
rem Extract updater
rem ==================================================

echo.
echo Extracting updater...

tar -xf "%TMP%\updater.zip" -C "%UPDATER_DIR%"


if errorlevel 1 (
    echo.
    echo ERROR: Failed extracting updater.
    pause
    exit /b 1
)


rem ==================================================
rem Create launcher in modpack root
rem ==================================================

echo.
echo Creating update.bat...


(
echo @echo off
echo call "%%~dp0.updater\updater.bat"
echo exit
) > "%ROOT%update.bat"


rem ==================================================
rem Cleanup
rem ==================================================

rd /s /q "%TMP%"


echo.
echo ==========================
echo Updater installed!
echo ==========================

echo.
echo Starting updater...


start "" "%ROOT%update.bat"


rem ==================================================
rem Self delete
rem ==================================================

start "" cmd /c "timeout /t 1 >nul & del /f /q "%~f0""

exit