@echo off
setlocal
title Disable WiiLink WFC DNS routing

set "SELF=%~f0"

powershell -NoProfile -Command "$p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()); if ($p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    echo Requesting administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
    exit /b
)

echo --------------------------------------------------
echo   WiiLink WFC - Disable DNS routing
echo --------------------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; $displayName = 'WiiLink WFC Nintendo DS'; $rules = @(Get-DnsClientNrptRule -ErrorAction SilentlyContinue ^| Where-Object { $_.DisplayName -eq $displayName }); foreach ($rule in $rules) { Remove-DnsClientNrptRule -Name $rule.Name -Force -ErrorAction Stop }; Clear-DnsClientCache"

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to remove WiiLink WFC DNS routing.
    pause
    exit /b 1
)

echo [OK] WiiLink WFC DNS routing has been removed.
echo Normal Windows DNS behavior is restored for *.nintendowifi.net.
echo.
pause
