# WFC DNS routing and service switching

Date: 2026-08-11

This document records the Windows NRPT design used to switch Nintendo DS WFC traffic between WiiLink and Wiimmfi/Kaeru WFC without changing the machine-wide DNS server.

## Shared namespace

Both helpers manage the same NRPT namespace:

```text
.nintendowifi.net
```

The leading `.` is intentional. It is required for the intended suffix/subdomain matching behavior, including hosts such as:

```text
nas.nintendowifi.net
*.gs.nintendowifi.net
```

The earlier WiiLink investigation showed that using `nintendowifi.net` without the leading dot did not route `nas.nintendowifi.net` through the selected DNS server as intended.

## Service DNS endpoints

### WiiLink WFC

```text
5.161.56.11
```

This path was confirmed with melonPrimeDS and Metroid Prime Hunters using an original, unmodified ROM.

### Wiimmfi / Kaeru WFC

```text
178.62.43.212
```

This is used as the Nintendo DS DNS endpoint for the Wiimmfi/Kaeru WFC path. It is a DNS server address, not a static replacement IP that should be written into the Windows hosts file for every Nintendo WFC hostname.

## Why NRPT instead of hosts

A hosts entry such as:

```text
178.62.43.212 nas.nintendowifi.net
```

would mean that the service itself lives at that IP.

That is not the intended behavior. The DNS server needs to answer each Nintendo WFC hostname independently. NRPT preserves that model by selecting which DNS server Windows should query for `.nintendowifi.net`.

Conceptually:

```text
Nintendo DS game
    -> melonDS/melonPrimeDS SLIRP DNS handler
    -> Windows getaddrinfo()
    -> Windows NRPT
    -> selected WFC DNS server
    -> service-specific DNS answer
    -> connection to the returned service address
```

## Mutual switching design

The repository manages two DisplayName values:

```text
WiiLink WFC Nintendo DS
Wiimmfi WFC Nintendo DS
```

Before either enable script adds its rule, it removes both of these managed rules.

Therefore only one repository-managed `.nintendowifi.net` rule is active at a time.

### Switch to WiiLink

Run:

```text
enable_WiiLink_WFC.bat
```

Result:

```text
.nintendowifi.net -> DNS 5.161.56.11
```

Any repository-managed Wiimmfi rule is removed first.

### Switch to Wiimmfi

Run:

```text
enable_Wiimmfi_WFC.bat
```

Result:

```text
.nintendowifi.net -> DNS 178.62.43.212
```

Any repository-managed WiiLink rule is removed first.

### Menu-based switch

Run:

```text
switch_WFC_DNS_service.bat
```

This is a thin menu wrapper around the same enable/disable scripts. The actual NRPT logic stays in the service-specific helpers.

### Restore normal DNS behavior

Run:

```text
disable_all_WFC_DNS_routing.bat
```

This removes both repository-managed NRPT rules and clears the Windows DNS cache. It intentionally does not remove unrelated NRPT rules created by the user, Windows policy, VPN software, enterprise management, or other applications.

Individual cleanup helpers are also provided:

```text
disable_WiiLink_WFC.bat
disable_Wiimmfi_WFC.bat
```

## Core PowerShell operations

WiiLink:

```powershell
Add-DnsClientNrptRule -Namespace ".nintendowifi.net" -NameServers "5.161.56.11" -DisplayName "WiiLink WFC Nintendo DS"
```

Wiimmfi / Kaeru WFC:

```powershell
Add-DnsClientNrptRule -Namespace ".nintendowifi.net" -NameServers "178.62.43.212" -DisplayName "Wiimmfi WFC Nintendo DS"
```

Validation:

```powershell
Get-DnsClientNrptPolicy -Effective | Where-Object { $_.Namespace -match "nintendowifi" }
Resolve-DnsName nas.nintendowifi.net -Type A
```

Clear cached answers after switching:

```powershell
Clear-DnsClientCache
```

## Relationship to WfcPatcher.exe

`WfcPatcher.exe` remains in this repository for the legacy Wiimmfi ROM-patching workflow.

AdmiralCurtiss/WfcPatcher performs string replacement inside the ROM. Its `--domain` path is separate from the NRPT method described here.

For WiiLink, testing established that an original ROM can work when `.nintendowifi.net` is correctly routed through WiiLink DNS, so the current WiiLink helper does not patch the ROM.

The legacy Wiimmfi helper remains available as:

```text
dragAndDropNdsFileToThisBatFile_wiimmfi_de.bat
```

## Operational caution

The enable scripts affect Windows name resolution for `*.nintendowifi.net` while active. They do not change the PC's global DNS server and do not intentionally modify unrelated NRPT namespaces.

If troubleshooting a connection, check the effective NRPT rule first before changing ROMs or patching domains.
