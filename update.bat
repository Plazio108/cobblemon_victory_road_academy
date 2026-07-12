@echo off
setlocal EnableDelayedExpansion

set "REPO_URL=https://github.com/Plazio108/cobblemon_victory_road_academy.git"
set "ROOT=%~dp0"
cd /d "%ROOT%"
set "TMP=%TEMP%\MinecraftUpdater"

echo ==== Minecraft Updater ====

if not exist ".git" (
  echo Cloning updater repository...
  git clone "%REPO_URL%" .
  if errorlevel 1 exit /b 1
  start "" "%~f0"
  exit
)

for /f %%B in ('git branch --show-current') do set "BRANCH=%%B"
git fetch origin --prune
git diff --quiet HEAD origin/%BRANCH%
if errorlevel 1 (
  echo Updating updater...
  git pull origin %BRANCH%
  if errorlevel 1 exit /b 1
  start "" "%~f0"
  exit
)

if not exist update.json (
  echo Missing update.json
  exit /b 1
)

echo Reading update information...

for /f "delims=" %%A in ('powershell -NoProfile -Command "^(Get-Content update.json -Raw ^| ConvertFrom-Json^).version"') do set "REMOTE_VERSION=%%A"

for /f "delims=" %%A in ('powershell -NoProfile -Command "^(Get-Content update.json -Raw ^| ConvertFrom-Json^).url"') do set "UPDATE_URL=%%A"

for /f "delims=" %%A in ('powershell -NoProfile -Command "^(Get-Content update.json -Raw ^| ConvertFrom-Json^).sha256"') do set "EXPECTED_HASH=%%A"

echo Version: %REMOTE_VERSION%
echo URL: %UPDATE_URL%
echo Hash: %EXPECTED_HASH%

if exist .installed_version set /p LOCAL_VERSION=<.installed_version
if /i "%LOCAL_VERSION%"=="%REMOTE_VERSION%" (
  echo Version %REMOTE_VERSION% already installed.
  exit /b 0
)

if exist "%TMP%" rd /s /q "%TMP%"
mkdir "%TMP%"

curl --ssl-no-revoke --fail --location --retry 3 --retry-delay 2 --retry-all-errors "%UPDATE_URL%" -o "%TMP%\update.zip"
if errorlevel 1 (
 rd /s /q "%TMP%"
 exit /b 1
)

for /f "tokens=1" %%H in ('certutil -hashfile "%TMP%\update.zip" SHA256 ^| findstr /R "^[0-9A-F]"') do set HASH=%%H
if /i not "%HASH%"=="%EXPECTED_HASH%" (
 echo SHA256 mismatch.
 rd /s /q "%TMP%"
 exit /b 1
)

tar -xf "%TMP%\update.zip" -C "%TMP%"
if errorlevel 1 (
 rd /s /q "%TMP%"
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

if exist mods rd /s /q mods
if exist datapacks rd /s /q datapacks
if exist resourcepacks rd /s /q resourcepacks

if exist "%SOURCE%\mods" robocopy "%SOURCE%\mods" "%ROOT%\mods" /E /R:2 /W:1 >nul
if exist "%SOURCE%\datapacks" robocopy "%SOURCE%\datapacks" "%ROOT%\datapacks" /E /R:2 /W:1 >nul
if exist "%SOURCE%\resourcepacks" robocopy "%SOURCE%\resourcepacks" "%ROOT%\resourcepacks" /E /R:2 /W:1 >nul

echo %REMOTE_VERSION%>.installed_version
rd /s /q "%TMP%"
echo Update complete.
pause
