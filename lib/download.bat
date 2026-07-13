@echo off
setlocal

set "URL=%~1"
set "OUTPUT=%~2"

echo Downloading:
echo %URL%
echo.

if "%URL%"=="" (
    echo ERROR: Missing URL
    exit /b 1
)

if "%OUTPUT%"=="" (
    echo ERROR: Missing output path
    exit /b 1
)

curl --ssl-no-revoke ^
     --fail ^
     --location ^
     --retry 3 ^
     --retry-delay 2 ^
     --retry-all-errors ^
     "%URL%" ^
     -o "%OUTPUT%"

if errorlevel 1 (
    echo ERROR: Download failed.
    exit /b 1
)

exit /b 0