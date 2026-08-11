# WiiLink/Wiimmfi switch design test checklist

Use this checklist when changing the DNS helper scripts.

1. Run `enable_WiiLink_WFC.bat`.
2. Confirm `Get-DnsClientNrptPolicy -Effective` shows `.nintendowifi.net` with `5.161.56.11`.
3. Run `enable_Wiimmfi_WFC.bat`.
4. Confirm the WiiLink DisplayName is gone and `.nintendowifi.net` now points to `178.62.43.212`.
5. Run `enable_WiiLink_WFC.bat` again and confirm the inverse switch.
6. Run `disable_all_WFC_DNS_routing.bat` and confirm neither repository-managed DisplayName remains.
7. Confirm unrelated NRPT rules, if any, were not removed.
8. Run `Resolve-DnsName nas.nintendowifi.net -Type A` after each switch to ensure the effective resolver result changes with the selected service.
