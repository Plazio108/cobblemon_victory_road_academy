@echo off
setlocal EnableDelayedExpansion

echo Checking updater version...

set "UPDATER_URL=https://github.com/Plazio108/cobblemon_victory_road_academy/releases/download/updater/updater.zip"

set "TEMP_UPDATE=%UPDATER_DIR%update_temp"
set "DOWNLOAD_DIR=%TEMP%\MinecraftUpdaterSelfUpdate"


if exist "%DOWNLOAD_DIR%" (
    rd /s /q "%DOWNLOAD_DIR%"
)

mkdir "%DOWNLOAD_DIR%"


echo Downloading updater package...


curl --ssl-no-revoke ^
     --fail ^
     --location ^
     --retry 3 ^
     --retry-delay 2 ^
     --retry-all-errors ^
     "%UPDATER_URL%" ^
     -o "%DOWNLOAD_DIR%\updater.zip"


if errorlevel 1 (
    echo Could not download updater update.
    rd /s /q "%DOWNLOAD_DIR%"
    exit /b 0
)


mkdir "%DOWNLOAD_DIR%\new"


echo Extracting updater...


tar -xf "%DOWNLOAD_DIR%\updater.zip" -C "%DOWNLOAD_DIR%\new"


if errorlevel 1 (
    echo Failed extracting updater.
    rd /s /q "%DOWNLOAD_DIR%"
    exit /b 0
)


if not exist "%DOWNLOAD_DIR%\new\version" (
    echo Missing updater version file.
    rd /s /q "%DOWNLOAD_DIR%"
    exit /b 0
)


set /p REMOTE_VERSION=<"%DOWNLOAD_DIR%\new\version"


set "LOCAL_VERSION=0"

if exist "%UPDATER_DIR%version" (
    set /p LOCAL_VERSION=<"%UPDATER_DIR%version"
)


echo Current updater:
echo %LOCAL_VERSION%

echo Available updater:
echo %REMOTE_VERSION%


if "%LOCAL_VERSION%"=="%REMOTE_VERSION%" (
    echo Updater already current.
    rd /s /q "%DOWNLOAD_DIR%"
    exit /b 0
)


echo New updater found.


rem Prepare update for restart.bat

if exist "%TEMP_UPDATE%" (
    rd /s /q "%TEMP_UPDATE%"
)

mkdir "%TEMP_UPDATE%"

xcopy "%DOWNLOAD_DIR%\new\*" "%TEMP_UPDATE%" /E /Y /I >nul


echo %REMOTE_VERSION%>"%TEMP_UPDATE%\version"


rd /s /q "%DOWNLOAD_DIR%"


echo Updater update prepared.

rem Tell updater.bat to restart through restart.bat
exit /b 2