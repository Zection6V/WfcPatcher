@echo off
setlocal
title Disable all WFC DNS routing

set "SELF=%~f0"

powershell -NoProfile -Command "$p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()); if ($p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    echo Requesting administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
    exit /b
)

echo --------------------------------------------------
echo   WFC DNS routing - Disable all managed rules
echo --------------------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; $managed = @('WiiLink WFC Nintendo DS','Wiimmfi WFC Nintendo DS'); foreach ($displayName in $managed) { $rules = @(Get-DnsClientNrptRule -ErrorAction SilentlyContinue ^| Where-Object { $_.DisplayName -eq $displayName }); foreach ($rule in $rules) { Remove-DnsClientNrptRule -Name $rule.Name -Force -ErrorAction Stop } }; Clear-DnsClientCache"

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to remove one or more managed WFC DNS rules.
    pause
    exit /b 1
)

echo [OK] WiiLink and Wiimmfi helper NRPT rules have been removed.
echo Normal Windows DNS behavior is restored for *.nintendowifi.net,
echo unless another NRPT rule outside this repository is configured.
echo.
pause
