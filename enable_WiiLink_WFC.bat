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
echo Routing *.nintendowifi.net through WiiLink DNS 5.161.56.11...

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; $displayName = 'WiiLink WFC Nintendo DS'; $rules = @(Get-DnsClientNrptRule -ErrorAction SilentlyContinue ^| Where-Object { $_.DisplayName -eq $displayName }); foreach ($rule in $rules) { Remove-DnsClientNrptRule -Name $rule.Name -Force -ErrorAction Stop }; Add-DnsClientNrptRule -Namespace '.nintendowifi.net' -NameServers '5.161.56.11' -DisplayName $displayName -ErrorAction Stop; Clear-DnsClientCache"

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to configure WiiLink WFC DNS routing.
    pause
    exit /b 1
)

echo.
echo [OK] WiiLink WFC DNS routing is enabled.
echo.
echo Current nas.nintendowifi.net resolution:
powershell -NoProfile -ExecutionPolicy Bypass -Command "Resolve-DnsName nas.nintendowifi.net -Type A -ErrorAction SilentlyContinue ^| Where-Object { $_.IPAddress } ^| Select-Object Name,IPAddress ^| Format-Table -AutoSize"
echo.
echo You can now use an original, unpatched NDS ROM.
echo Run disable_WiiLink_WFC.bat when you want to restore normal DNS behavior.
echo.
pause
