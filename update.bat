@echo off
setlocal EnableDelayedExpansion

echo ==== Minecraft Updater ====

set "UPDATER_DIR=%~dp0"
set "ROOT=%UPDATER_DIR%.."
set "REPO_DIR=%UPDATER_DIR%repo"
set "TMP=%TEMP%\MinecraftUpdater"

set "REPO_URL=https://github.com/Plazio108/cobblemon_victory_road_academy.git"

cd /d "%UPDATER_DIR%"

rem Check Git
git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed or not in PATH.
    pause
    exit /b 1
)

rem Clone updater repository
if not exist "%REPO_DIR%\.git" (
    echo Cloning updater repository...

    if exist "%REPO_DIR%" rd /s /q "%REPO_DIR%"

    git clone "%REPO_URL%" "%REPO_DIR%"

    if errorlevel 1 (
        echo ERROR: Failed to clone repository.
        pause
        exit /b 1
    )

    echo Restarting from cloned updater...
    call "%REPO_DIR%\update.bat"
    exit /b
)

rem Update updater repository
cd /d "%REPO_DIR%"

for /f %%B in ('git branch --show-current') do set "BRANCH=%%B"

git fetch origin --prune

git diff --quiet HEAD origin/%BRANCH%
if errorlevel 1 (
    echo Updating updater...

    git pull origin %BRANCH%

    if errorlevel 1 (
        echo ERROR: Failed to update updater.
        pause
        exit /b 1
    )

    echo Restarting updated updater...
    call "%REPO_DIR%\update.bat"
    exit /b
)

rem Read update file
if not exist "%REPO_DIR%\update" (
    echo ERROR: Missing update file.
    pause
    exit /b 1
)

set "REMOTE_VERSION="
set "UPDATE_URL="
set "EXPECTED_HASH="

for /f "delims=" %%A in (%REPO_DIR%\update) do (
    if not defined REMOTE_VERSION (
        set "REMOTE_VERSION=%%A"
    ) else if not defined UPDATE_URL (
        set "UPDATE_URL=%%A"
    ) else (
        set "EXPECTED_HASH=%%A"
    )
)

echo Version: %REMOTE_VERSION%
echo URL: %UPDATE_URL%
echo Hash: %EXPECTED_HASH%

if exist "%ROOT%\.installed_version" (
    set /p LOCAL_VERSION=<"%ROOT%\.installed_version"
)

if "%LOCAL_VERSION%"=="%REMOTE_VERSION%" (
    echo Version %REMOTE_VERSION% already installed.
    pause
    exit /b 0
)

if exist "%TMP%" rd /s /q "%TMP%"
mkdir "%TMP%"

echo Downloading update...

curl --ssl-no-revoke --fail --location --retry 3 --retry-delay 2 --retry-all-errors "%UPDATE_URL%" -o "%TMP%\update.zip"

if errorlevel 1 (
    echo ERROR: Download failed.
    rd /s /q "%TMP%"
    pause
    exit /b 1
)

echo Checking SHA256...

for /f "tokens=1" %%H in ('certutil -hashfile "%TMP%\update.zip" SHA256 ^| findstr /R "^[0-9A-F]"') do (
    set "HASH=%%H"
)

if /i not "%HASH%"=="%EXPECTED_HASH%" (
    echo ERROR: SHA256 mismatch.
    echo Expected: %EXPECTED_HASH%
    echo Got: %HASH%
    rd /s /q "%TMP%"
    pause
    exit /b 1
)

echo Extracting update...

tar -xf "%TMP%\update.zip" -C "%TMP%"

if errorlevel 1 (
    echo ERROR: Extraction failed.
    rd /s /q "%TMP%"
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

echo Installing files...

if exist "%ROOT%\mods" rd /s /q "%ROOT%\mods"
if exist "%ROOT%\datapacks" rd /s /q "%ROOT%\datapacks"
if exist "%ROOT%\resourcepacks" rd /s /q "%ROOT%\resourcepacks"

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
echo =====================
echo Update complete!
echo Installed version: %REMOTE_VERSION%
echo =====================

pause