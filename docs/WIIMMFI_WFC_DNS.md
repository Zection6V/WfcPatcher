# Wiimmfi DNS helper notes

Date: 2026-08-11

The repository uses `178.62.43.212` as the Nintendo DS DNS endpoint for the Wiimmfi/Kaeru WFC route.

The helper is implemented as a Windows NRPT rule rather than a static hosts entry:

```powershell
Add-DnsClientNrptRule -Namespace ".nintendowifi.net" -NameServers "178.62.43.212" -DisplayName "Wiimmfi WFC Nintendo DS"
Clear-DnsClientCache
```

The runtime helper is:

```text
enable_Wiimmfi_WFC.bat
```

It first removes both repository-managed WFC NRPT rules (`WiiLink WFC Nintendo DS` and `Wiimmfi WFC Nintendo DS`) and then adds only the Wiimmfi rule. This makes service switching deterministic and prevents the repository from leaving two competing rules for the same namespace.

To switch back to WiiLink, run:

```text
enable_WiiLink_WFC.bat
```

To restore normal Windows DNS behavior for this repository's managed rules, run:

```text
disable_all_WFC_DNS_routing.bat
```

The legacy ROM-patching helper remains available separately as:

```text
dragAndDropNdsFileToThisBatFile_wiimmfi_de.bat
```

The NRPT path and the legacy `WfcPatcher.exe --domain wiimmfi.de` path are different mechanisms and are intentionally kept separate.
