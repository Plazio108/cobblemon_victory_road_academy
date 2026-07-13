@echo off
@echo off
setlocal

echo Restarting updater...

rem Wait for the old updater.bat process to close
timeout /t 2 /nobreak >nul

set "UPDATER_DIR=%~dp0"
set "TEMP_UPDATE=%UPDATER_DIR%update_temp"

if not exist "%TEMP_UPDATE%" (
    echo ERROR: Missing update_temp folder.
    pause
    exit /b 1
)

echo Installing new updater files...

xcopy "%TEMP_UPDATE%\*" "%UPDATER_DIR%" /E /Y /I >nul

if errorlevel 1 (
    echo ERROR: Failed replacing updater files.
    pause
    exit /b 1
)

rd /s /q "%TEMP_UPDATE%"

echo Restarting updater...

start "" "%UPDATER_DIR%updater.bat"

exit /b 0