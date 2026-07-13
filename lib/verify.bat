@echo off
setlocal EnableDelayedExpansion

set "FILE=%~1"
set "EXPECTED=%~2"

if not exist "%FILE%" exit /b 1

set "HASH="

for /f "skip=1 tokens=1" %%H in ('certutil -hashfile "%FILE%" SHA256') do (
    if not defined HASH set "HASH=%%H"
)

echo Expected:
echo %EXPECTED%

echo Got:
echo %HASH%

if /i "%HASH%"=="%EXPECTED%" (
    echo Hash OK.
    exit /b 0
)

echo Hash mismatch.
exit /b 1