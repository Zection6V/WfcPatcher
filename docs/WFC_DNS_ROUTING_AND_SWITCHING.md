# WFC DNS routing and service switching

Date: 2026-08-11

This document records the Windows NRPT design used to switch Nintendo DS WFC traffic between WiiLink and Wiimmfi/Kaeru WFC without changing the machine-wide DNS server.

## Shared namespace

Both helpers manage:

```text
.nintendowifi.net
```

The leading `.` is intentional and required for suffix/subdomain matching such as `nas.nintendowifi.net` and `*.gs.nintendowifi.net`.

## Service DNS endpoints

### WiiLink WFC

```text
5.161.56.11
```

Confirmed with melonPrimeDS + Metroid Prime Hunters using an original, unmodified ROM.

### Wiimmfi / Kaeru WFC

```text
178.62.43.212
```

This is treated as the Nintendo DS DNS endpoint for the Wiimmfi/Kaeru WFC path.

## Why NRPT instead of hosts

A hosts entry maps a hostname directly to an IP address. That is not equivalent to selecting a DNS server. NRPT lets Windows ask the selected DNS server for each `*.nintendowifi.net` hostname independently.

Conceptually:

```text
Nintendo DS game
    -> melonDS/melonPrimeDS SLIRP DNS handler
    -> Windows getaddrinfo()
    -> Windows NRPT
    -> selected WFC DNS server
    -> service-specific DNS answer
```

## Mutual switching design

The repository manages only these DisplayName values:

```text
WiiLink WFC Nintendo DS
Wiimmfi WFC Nintendo DS
```

Before either enable script adds its own rule, it removes both managed rules. Therefore the repository intentionally keeps at most one active WFC DNS-routing rule.

### Switch to WiiLink

```text
enable_WiiLink_WFC.bat
```

Result:

```text
.nintendowifi.net -> DNS 5.161.56.11
```

### Switch to Wiimmfi

```text
enable_Wiimmfi_WFC.bat
```

Result:

```text
.nintendowifi.net -> DNS 178.62.43.212
```

## Important: DNS switching is not WFC profile switching

The DNS helper changes where `*.nintendowifi.net` is resolved, but it does not rewrite or migrate the Nintendo DS WFC user information stored by the game/system.

A practical consequence is that after connecting to one replacement server, switching DNS routing to a different replacement server while reusing the same existing DS WFC user information can result in error `60000`.

Example:

```text
Connect to WiiLink
    -> WiiLink-side WFC user/profile state is established
Switch NRPT to Wiimmfi
    -> DS still carries the previous WFC user information
    -> error 60000 may occur
```

If error `60000` occurs after switching servers:

1. Open the Nintendo DS Wi-Fi Connection settings.
2. Delete the existing WFC user information/profile.
3. Connect again so the newly selected server can create/register new WFC user information.

For frequent multi-server use, keep separate emulator data directories or separate emulator copies for WiiLink and Wiimmfi. Each environment can then retain the WFC user information associated with its own server.

This means there are two independent pieces of state:

```text
Host side: Windows NRPT / selected DNS server
DS side:   WFC user information/profile
```

Both must correspond to the server being used.

### Show current DNS-routing state

```text
show_WFC_DNS_status.bat
```

This reports:

- active repository-managed service, if any
- NRPT namespace
- configured DNS server
- current IPv4 answer(s) for `nas.nintendowifi.net`

It does not inspect the DS WFC user profile itself.

If more than one repository-managed NRPT rule somehow exists, the status helper prints a warning.

### Restore normal DNS behavior

```text
remove_WFC_DNS_routing.bat
```

This removes both repository-managed DisplayName values and clears the Windows DNS cache. It intentionally leaves unrelated NRPT rules alone.

### Menu wrapper

```text
switch_WFC_DNS_service.bat
```

Options are WiiLink, Wiimmfi, status, and remove/restore-normal-DNS.

## PowerShell/cmd.exe escaping bug found in Release1.6.0.7

The first Wiimmfi helper version embedded PowerShell pipelines inside a quoted `powershell -Command` string and wrote them as:

```text
^|
```

That was incorrect in this context. The caret reached PowerShell as a literal argument, producing errors such as:

```text
Resolve-DnsName : A positional parameter cannot be found that accepts argument '^'.
```

The corrected helpers avoid PowerShell pipelines inside the batch `-Command` strings entirely. They assign command results to variables and use `foreach`/`if` logic instead. This removes the cmd.exe/PowerShell pipe-escaping ambiguity rather than adding another escape workaround.

## Core PowerShell operations

WiiLink:

```powershell
Add-DnsClientNrptRule -Namespace ".nintendowifi.net" -NameServers "5.161.56.11" -DisplayName "WiiLink WFC Nintendo DS"
```

Wiimmfi / Kaeru WFC:

```powershell
Add-DnsClientNrptRule -Namespace ".nintendowifi.net" -NameServers "178.62.43.212" -DisplayName "Wiimmfi WFC Nintendo DS"
```

Clear cached answers after switching:

```powershell
Clear-DnsClientCache
```

## Relationship to WfcPatcher.exe

`WfcPatcher.exe` remains only for the legacy ROM-patching workflow. AdmiralCurtiss/WfcPatcher changes strings inside a ROM; that is separate from the host-side NRPT routing described here.

Legacy Wiimmfi helper:

```text
dragAndDropNdsFileToThisBatFile_wiimmfi_de.bat
```

For WiiLink, testing established that an original ROM works when `.nintendowifi.net` is routed through WiiLink DNS, so current WiiLink operation does not require ROM patching.

## Operational caution

The enable scripts affect Windows name resolution for `*.nintendowifi.net` while active. They do not change the PC's global DNS server and do not intentionally modify unrelated NRPT namespaces.

When troubleshooting, first run `show_WFC_DNS_status.bat`. If DNS routing is correct but the game reports `60000` after changing servers, check/reset the DS WFC user information next.
