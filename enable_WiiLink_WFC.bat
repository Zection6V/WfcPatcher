@echo off
setlocal
title Enable WiiLink WFC DNS routing

set "SELF=%~f0"

powershell -NoProfile -Command "$p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()); if ($p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    echo Requesting administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
    exit /b
)

echo --------------------------------------------------
echo   WiiLink WFC - Enable DNS routing
echo --------------------------------------------------
echo.
echo Switching WFC DNS routing to WiiLink...
echo Namespace:  .nintendowifi.net
echo DNS server: 5.161.56.11
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; $managed = @('WiiLink WFC Nintendo DS','Wiimmfi WFC Nintendo DS'); $rules = @(Get-DnsClientNrptRule -ErrorAction SilentlyContinue); foreach ($rule in $rules) { if ($managed -contains $rule.DisplayName) { Remove-DnsClientNrptRule -Name $rule.Name -Force -ErrorAction Stop } }; Add-DnsClientNrptRule -Namespace '.nintendowifi.net' -NameServers '5.161.56.11' -DisplayName 'WiiLink WFC Nintendo DS' -ErrorAction Stop; Clear-DnsClientCache"

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to configure WiiLink WFC DNS routing.
    pause
    exit /b 1
)

echo.
echo [OK] WiiLink WFC DNS routing is enabled.
echo [OK] Any Wiimmfi helper rule from this repository was removed.
echo.
call "%~dp0show_WFC_DNS_status.bat" /nopause
echo.
echo IMPORTANT WHEN SWITCHING SERVERS:
echo If you previously connected to another WFC server and get error 60000,
echo delete the existing WFC user information from the DS Wi-Fi Connection settings
echo and let the game create new user information for WiiLink.
echo To keep profiles for multiple servers, use separate emulator data/folders.
echo.
echo Run enable_Wiimmfi_WFC.bat to switch DNS routing to Wiimmfi.
echo Run remove_WFC_DNS_routing.bat to restore normal DNS behavior.
echo.
pause
