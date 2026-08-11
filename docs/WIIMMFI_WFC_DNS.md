# Wiimmfi DNS helper notes

Date: 2026-08-11

The repository uses `178.62.43.212` as the Nintendo DS DNS endpoint for the Wiimmfi/Kaeru WFC route.

The helper is implemented as a Windows NRPT rule rather than a static hosts entry:

```powershell
Add-DnsClientNrptRule -Namespace ".nintendowifi.net" -NameServers "178.62.43.212" -DisplayName "Wiimmfi WFC Nintendo DS"
Clear-DnsClientCache
```

Runtime helper:

```text
enable_Wiimmfi_WFC.bat
```

It removes both repository-managed WFC rules first and then adds only the Wiimmfi rule. This makes switching deterministic and prevents two competing repository-managed rules for the same namespace.

Switch back to WiiLink:

```text
enable_WiiLink_WFC.bat
```

Show the current state:

```text
show_WFC_DNS_status.bat
```

Restore normal Windows DNS behavior for the repository-managed rules:

```text
remove_WFC_DNS_routing.bat
```

The Release1.6.0.7 helper contained an escaping bug in diagnostic PowerShell commands: `^|` was passed through to PowerShell as a literal caret. The corrected scripts avoid PowerShell pipelines inside quoted batch `-Command` strings entirely.

The legacy ROM-patching helper remains available separately:

```text
dragAndDropNdsFileToThisBatFile_wiimmfi_de.bat
```

The NRPT path and the legacy `WfcPatcher.exe --domain wiimmfi.de` path are different mechanisms and are intentionally kept separate.
