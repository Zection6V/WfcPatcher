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

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; $managed = @('WiiLink WFC Nintendo DS','Wiimmfi WFC Nintendo DS'); foreach ($displayName in $managed) { $rules = @(Get-DnsClientNrptRule -ErrorAction SilentlyContinue ^| Where-Object { $_.DisplayName -eq $displayName }); foreach ($rule in $rules) { Remove-DnsClientNrptRule -Name $rule.Name -Force -ErrorAction Stop } }; Add-DnsClientNrptRule -Namespace '.nintendowifi.net' -NameServers '178.62.43.212' -DisplayName 'Wiimmfi WFC Nintendo DS' -ErrorAction Stop; Clear-DnsClientCache"

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
echo Current nas.nintendowifi.net resolution:
powershell -NoProfile -ExecutionPolicy Bypass -Command "Resolve-DnsName nas.nintendowifi.net -Type A -ErrorAction SilentlyContinue ^| Where-Object { $_.IPAddress } ^| Select-Object Name,IPAddress ^| Format-Table -AutoSize"
echo.
echo Run enable_WiiLink_WFC.bat to switch to WiiLink.
echo Run disable_all_WFC_DNS_routing.bat to restore normal DNS behavior.
echo.
pause
