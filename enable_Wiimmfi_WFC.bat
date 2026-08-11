@echo off
setlocal
title Enable Wiimmfi WFC DNS routing

set "SELF=%~f0"

powershell -NoProfile -Command "$p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()); if ($p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    echo Requesting administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
    exit /b
)

echo --------------------------------------------------
echo   Wiimmfi WFC - Enable DNS routing
echo --------------------------------------------------
echo.
echo Switching WFC DNS routing to Wiimmfi / Kaeru WFC...
echo Namespace:  .nintendowifi.net
echo DNS server: 178.62.43.212
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; $managed = @('WiiLink WFC Nintendo DS','Wiimmfi WFC Nintendo DS'); $rules = @(Get-DnsClientNrptRule -ErrorAction SilentlyContinue); foreach ($rule in $rules) { if ($managed -contains $rule.DisplayName) { Remove-DnsClientNrptRule -Name $rule.Name -Force -ErrorAction Stop } }; Add-DnsClientNrptRule -Namespace '.nintendowifi.net' -NameServers '178.62.43.212' -DisplayName 'Wiimmfi WFC Nintendo DS' -ErrorAction Stop; Clear-DnsClientCache"

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to configure Wiimmfi WFC DNS routing.
    pause
    exit /b 1
)

echo.
echo [OK] Wiimmfi WFC DNS routing is enabled.
echo [OK] Any WiiLink helper rule from this repository was removed.
echo.
call "%~dp0show_WFC_DNS_status.bat" /nopause
echo.
echo IMPORTANT WHEN SWITCHING SERVERS:
echo If you previously connected to another WFC server and get error 60000,
echo delete the existing WFC user information from the DS Wi-Fi Connection settings
echo and let the game create new user information for Wiimmfi / Kaeru WFC.
echo To keep profiles for multiple servers, use separate emulator data/folders.
echo.
echo Run enable_WiiLink_WFC.bat to switch DNS routing to WiiLink.
echo Run remove_WFC_DNS_routing.bat to restore normal DNS behavior.
echo.
pause
