@echo off
setlocal EnableDelayedExpansion

echo ==== Minecraft Updater ====

set "UPDATER_DIR=%~dp0"
set "ROOT=%UPDATER_DIR%.."
set "TMP=%TEMP%\MinecraftUpdater"

set "REPO_URL=https://github.com/Plazio108/cobblemon_victory_road_academy.git"

cd /d "%UPDATER_DIR%"

rem ==================================================
rem Check Git repository
rem ==================================================

if not exist ".git" (
    echo ERROR: .updater is not a Git repository.
    echo Delete .updater and clone the repository there first.
    pause
    exit /b 1
)

rem ==================================================
rem Update updater files
rem ==================================================

echo Updating updater...

for /f %%B in ('git branch --show-current') do set "BRANCH=%%B"

git fetch origin --prune

git diff --quiet HEAD origin/%BRANCH%
if errorlevel 1 (
    echo New updater version found.

    git pull origin %BRANCH%

    if errorlevel 1 (
        echo ERROR: Failed to update updater.
        pause
        exit /b 1
    )

    echo Restarting updated updater...

    call "%UPDATER_DIR%update.bat"
    exit /b
)

rem ==================================================
rem Read update file
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
echo Remote version: %REMOTE_VERSION%
echo Download URL: %UPDATE_URL%
echo.

rem ==================================================
rem Check installed version
rem ==================================================

if exist "%ROOT%\.installed_version" (
    set /p LOCAL_VERSION=<"%ROOT%\.installed_version"
)

if "%LOCAL_VERSION%"=="%REMOTE_VERSION%" (
    echo Already up to date.
    echo Version: %REMOTE_VERSION%
    pause
    exit /b 0
)

rem ==================================================
rem Download update
rem ==================================================

if exist "%TMP%" rd /s /q "%TMP%"

mkdir "%TMP%"

echo Downloading update...

curl --ssl-no-revoke --fail --location --retry 3 --retry-delay 2 --retry-all-errors "%UPDATE_URL%" -o "%TMP%\update.zip"

if errorlevel 1 (
    echo ERROR: Download failed.
    pause
    exit /b 1
)

rem ==================================================
rem Verify SHA256
rem ==================================================

echo Checking SHA256...

for /f "tokens=1" %%H in ('certutil -hashfile "%TMP%\update.zip" SHA256 ^| findstr /R "^[0-9A-F]"') do (
    set "HASH=%%H"
)

if /i not "%HASH%"=="%EXPECTED_HASH%" (
    echo ERROR: SHA256 mismatch.
    echo Expected:
    echo %EXPECTED_HASH%
    echo Got:
    echo %HASH%
    pause
    exit /b 1
)

echo Hash OK.

rem ==================================================
rem Extract update
rem ==================================================

echo Extracting...

tar -xf "%TMP%\update.zip" -C "%TMP%"

if errorlevel 1 (
    echo ERROR: Extraction failed.
    pause
    exit /b 1
)

set "SOURCE=%TMP%"

if not exist "%SOURCE%\mods" (
    for /d %%D in ("%TMP%\*") do (
        if exist "%%~fD\mods" (
            set "SOURCE=%%~fD"
            goto found
        )
    )
)

:found

rem ==================================================
rem Install files
rem ==================================================

echo Installing update...

if exist "%ROOT%\mods" (
    rd /s /q "%ROOT%\mods"
)

if exist "%ROOT%\datapacks" (
    rd /s /q "%ROOT%\datapacks"
)

if exist "%ROOT%\resourcepacks" (
    rd /s /q "%ROOT%\resourcepacks"
)

if exist "%SOURCE%\mods" (
    robocopy "%SOURCE%\mods" "%ROOT%\mods" /E /R:2 /W:1 >nul
)

if exist "%SOURCE%\datapacks" (
    robocopy "%SOURCE%\datapacks" "%ROOT%\datapacks" /E /R:2 /W:1 >nul
)

if exist "%SOURCE%\resourcepacks" (
    robocopy "%SOURCE%\resourcepacks" "%ROOT%\resourcepacks" /E /R:2 /W:1 >nul
)

echo %REMOTE_VERSION%>"%ROOT%\.installed_version"

rd /s /q "%TMP%"

echo.
echo ======================
echo Update complete!
echo Version %REMOTE_VERSION%
echo ======================

pause