@echo off
setlocal
title Disable Wiimmfi WFC DNS routing

set "SELF=%~f0"

powershell -NoProfile -Command "$p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()); if ($p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    echo Requesting administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
    exit /b
)

echo --------------------------------------------------
echo   Wiimmfi WFC - Disable DNS routing
echo --------------------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; $displayName = 'Wiimmfi WFC Nintendo DS'; $rules = @(Get-DnsClientNrptRule -ErrorAction SilentlyContinue ^| Where-Object { $_.DisplayName -eq $displayName }); foreach ($rule in $rules) { Remove-DnsClientNrptRule -Name $rule.Name -Force -ErrorAction Stop }; Clear-DnsClientCache"

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to remove Wiimmfi WFC DNS routing.
    pause
    exit /b 1
)

echo [OK] Wiimmfi WFC DNS routing has been removed.
echo If the WiiLink helper rule is active, it remains active.
echo Use disable_all_WFC_DNS_routing.bat to remove both helper rules.
echo.
pause
