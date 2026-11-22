@echo off
setlocal

cmake -S . -B build
if errorlevel 1 exit /b 1

cmake --build build --config Release
if errorlevel 1 exit /b 1

ctest --test-dir build -C Release --output-on-failure
if errorlevel 1 exit /b 1

if not exist dist mkdir dist
if errorlevel 1 exit /b 1

copy /Y build\Release\hello.exe dist\hello.exe
if errorlevel 1 exit /b 1

exit /b 0
