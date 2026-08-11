@echo off
setlocal
title WFC DNS routing status

echo --------------------------------------------------
echo   Nintendo DS WFC DNS routing status
echo --------------------------------------------------
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$managed = @('WiiLink WFC Nintendo DS','Wiimmfi WFC Nintendo DS'); $rules = @(Get-DnsClientNrptRule -ErrorAction SilentlyContinue); $found = @(); foreach ($rule in $rules) { if ($managed -contains $rule.DisplayName) { $found += $rule } }; if ($found.Count -eq 0) { Write-Host '[STATUS] Normal DNS'; Write-Host 'No repository-managed WiiLink/Wiimmfi NRPT rule is active.' } else { if ($found.Count -gt 1) { Write-Host '[WARNING] More than one repository-managed WFC rule is active.'; Write-Host '' }; foreach ($rule in $found) { if ($rule.DisplayName -eq 'WiiLink WFC Nintendo DS') { $service = 'WiiLink WFC' } else { $service = 'Wiimmfi / Kaeru WFC' }; Write-Host ('[ACTIVE] ' + $service); Write-Host ('Namespace:  ' + ($rule.Namespace -join ', ')); Write-Host ('DNS server: ' + ($rule.NameServers -join ', ')); Write-Host '' } }; Write-Host 'Current nas.nintendowifi.net IPv4 resolution:'; $answers = @(Resolve-DnsName nas.nintendowifi.net -Type A -ErrorAction SilentlyContinue); $printed = $false; foreach ($answer in $answers) { if ($answer.IPAddress) { Write-Host ('  ' + $answer.IPAddress); $printed = $true } }; if (-not $printed) { Write-Host '  [No IPv4 answer]' }"

echo.
if /I "%~1"=="/nopause" exit /b 0
pause
