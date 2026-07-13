@echo off
setlocal EnableDelayedExpansion

set "ZIP=%~1"

if not exist "%ZIP%" exit /b 1

set "EXTRACT=%TEMP%\MinecraftUpdaterExtract"

if exist "%EXTRACT%" (
    rd /s /q "%EXTRACT%"
)

mkdir "%EXTRACT%"

echo Extracting...

tar -xf "%ZIP%" -C "%EXTRACT%"

if errorlevel 1 (
    echo Extraction failed.
    exit /b 1
)

set "SOURCE=%EXTRACT%"

if not exist "%SOURCE%\mods" (
    for /d %%D in ("%EXTRACT%\*") do (
        if exist "%%~fD\mods" (
            set "SOURCE=%%~fD"
        )
    )
)

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

rd /s /q "%EXTRACT%"

exit /b 0