@echo off
setlocal
title Remove WFC DNS routing

set "SELF=%~f0"

powershell -NoProfile -Command "$p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()); if ($p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    echo Requesting administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
    exit /b
)

echo --------------------------------------------------
echo   WFC DNS routing - Remove managed rule
echo --------------------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; $managed = @('WiiLink WFC Nintendo DS','Wiimmfi WFC Nintendo DS'); $rules = @(Get-DnsClientNrptRule -ErrorAction SilentlyContinue); foreach ($rule in $rules) { if ($managed -contains $rule.DisplayName) { Remove-DnsClientNrptRule -Name $rule.Name -Force -ErrorAction Stop } }; Clear-DnsClientCache"

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to remove the managed WFC DNS rule.
    pause
    exit /b 1
)

echo [OK] Repository-managed WiiLink/Wiimmfi NRPT rules have been removed.
echo Normal Windows DNS behavior is restored for *.nintendowifi.net,
echo unless another NRPT rule outside this repository is configured.
echo.
call "%~dp0show_WFC_DNS_status.bat" /nopause
echo.
pause
