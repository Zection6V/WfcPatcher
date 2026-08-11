@echo off
setlocal
title Switch WFC DNS service

echo --------------------------------------------------
echo   Nintendo DS WFC DNS service switcher
echo --------------------------------------------------
echo.
echo 1. WiiLink WFC              - 5.161.56.11
echo 2. Wiimmfi / Kaeru WFC      - 178.62.43.212
echo 3. Show current status
echo 4. Remove WFC DNS routing / restore normal DNS
echo 0. Cancel
echo.
set /p "CHOICE=Select: "

if "%CHOICE%"=="1" (
    call "%~dp0enable_WiiLink_WFC.bat"
    exit /b
)
if "%CHOICE%"=="2" (
    call "%~dp0enable_Wiimmfi_WFC.bat"
    exit /b
)
if "%CHOICE%"=="3" (
    call "%~dp0show_WFC_DNS_status.bat"
    exit /b
)
if "%CHOICE%"=="4" (
    call "%~dp0remove_WFC_DNS_routing.bat"
    exit /b
)
if "%CHOICE%"=="0" exit /b

echo.
echo [ERROR] Invalid selection.
pause
