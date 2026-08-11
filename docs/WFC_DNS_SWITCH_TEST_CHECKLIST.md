# WiiLink/Wiimmfi switch design test checklist

Use this checklist when changing the DNS helper scripts.

1. Run `show_WFC_DNS_status.bat` and record the initial state.
2. Run `enable_WiiLink_WFC.bat`.
3. Confirm status shows WiiLink, `.nintendowifi.net`, and DNS `5.161.56.11`.
4. Confirm no `^`/pipeline parsing error appears.
5. Run `enable_Wiimmfi_WFC.bat`.
6. Confirm status now shows Wiimmfi/Kaeru WFC and DNS `178.62.43.212`.
7. Confirm the WiiLink DisplayName is no longer active.
8. Run `enable_WiiLink_WFC.bat` again and confirm the inverse switch.
9. Run `remove_WFC_DNS_routing.bat`.
10. Confirm status reports normal DNS / no repository-managed WFC rule.
11. Confirm unrelated NRPT rules, if any, were not removed.
12. Confirm `nas.nintendowifi.net` IPv4 resolution is displayed by the status helper after each state change.

No separate switcher is required: running either enable script must directly switch the active service by removing the other repository-managed rule first.

Implementation rule: avoid PowerShell pipelines inside quoted `.bat` `powershell -Command` strings. Prefer variable assignment plus `foreach`/`if` logic to avoid cmd.exe/PowerShell escaping ambiguity.
