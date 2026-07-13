@echo off
setlocal

set "URL=%~1"
set "OUTPUT=%~2"

if "%URL%"=="" exit /b 1
if "%OUTPUT%"=="" exit /b 1

echo Downloading:
echo %URL%

curl --ssl-no-revoke ^
     --fail ^
     --location ^
     --retry 3 ^
     --retry-delay 2 ^
     --retry-all-errors ^
     "%URL%" ^
     -o "%OUTPUT%"

if errorlevel 1 (
    echo Download failed.
    exit /b 1
)

exit /b 0