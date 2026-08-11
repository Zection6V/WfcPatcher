# WiiLink WFC DNS investigation notes

Date: 2026-08-11

This document records the investigation that led to the current WiiLink WFC setup used by this repository.

## Final confirmed result

For Metroid Prime Hunters on melonPrimeDS/Windows, WiiLink WFC works with an **original, unmodified NDS ROM** when Windows resolves `*.nintendowifi.net` through the WiiLink WFC DNS server.

The working Windows NRPT rule is:

```powershell
Add-DnsClientNrptRule -Namespace ".nintendowifi.net" -NameServers "5.161.56.11" -DisplayName "WiiLink WFC Nintendo DS"
Clear-DnsClientCache
```

The leading `.` in `.nintendowifi.net` is required for the intended suffix/subdomain matching behavior.

Removal:

```powershell
Get-DnsClientNrptRule |
    Where-Object DisplayName -eq "WiiLink WFC Nintendo DS" |
    Remove-DnsClientNrptRule -Force

Clear-DnsClientCache
```

The repository provides `enable_WiiLink_WFC.bat` and `disable_WiiLink_WFC.bat` so users do not need to enter these commands manually.

## Important addresses

- WiiLink WFC DNS server: `5.161.56.11`
- During the investigation, querying that DNS server directly returned `5.161.56.110` for `nas.nintendowifi.net`.

Example:

```powershell
Resolve-DnsName nas.nintendowifi.net -Server 5.161.56.11
```

Observed result on 2026-08-11:

```text
nas.nintendowifi.net  A  5.161.56.110
```

`5.161.56.110` is an observed service address, not something this repository should hard-code. The authoritative item for the client setup is the WiiLink DNS server `5.161.56.11`.

## What did not work

### 1. Old WiiLink replacement domain

The original helper used:

```text
--domain wiilink24.com
```

This used to work, but WiiLink migrated its WFC domain from `wiilink24.com` to `wiilink.ca` in 2026.

Relevant official WiiLink commit:

https://github.com/WiiLink24/wfc-patcher-wii/commit/4925d040e38c519f9a3982b75ebd39efd257c226

### 2. Replacing the ROM domain with `wiilink.ca`

Changing the batch to:

```text
--domain wiilink.ca
```

also did not restore connectivity.

This was the key sign that WiiLink's current Nintendo DS path should not be treated as a simple replacement-domain service.

### 3. Incorrect NRPT namespace

The first NRPT attempt used:

```powershell
-Namespace "nintendowifi.net"
```

That rule did not affect `nas.nintendowifi.net` as intended.

A normal lookup still returned Nintendo/AWS infrastructure, for example:

```text
nas.nintendowifi.net
  -> CNAME ...elb.us-west-2.amazonaws.com
  -> 44.245.86.170 / 54.201.103.197
```

At the same time, explicitly querying WiiLink DNS worked:

```powershell
Resolve-DnsName nas.nintendowifi.net -Server 5.161.56.11
```

and returned the WiiLink address.

Changing the NRPT namespace to:

```powershell
-Namespace ".nintendowifi.net"
```

made the normal Windows resolver return the WiiLink result. This was the decisive DNS fix.

## WfcPatcher behavior

Reference repository:

https://github.com/AdmiralCurtiss/WfcPatcher

The relevant implementation is in `Program.cs`.

WfcPatcher performs two important string replacements:

```csharp
ReplaceInData(data, "https://", "http://", ...);
```

and, only when `--domain` is supplied:

```csharp
ReplaceInData(data, "nintendowifi.net", CommandLineArguments.Domain, ...);
```

Therefore:

```text
WfcPatcher game.nds --domain example.com
```

means roughly:

```text
https://            -> http://
nintendowifi.net    -> example.com
```

It does not make `--domain` a generic WiiLink-aware patch. In particular, the current WiiLink WFC setup is not reproduced merely by replacing `nintendowifi.net` with `wiilink.ca`.

## NoSSL test

A useful intermediate test was running WfcPatcher without `--domain`:

```text
WfcPatcher.exe game.nds
```

This creates a NoSSL-patched ROM where the `nintendowifi.net` names remain intact while `https://` is changed to `http://`.

With the corrected NRPT rule, this ROM connected successfully.

However, a later test showed that an **original ROM without the NoSSL patch also connects successfully**.

Therefore the final conclusion is:

- `--domain wiilink.ca` is not needed.
- NoSSL patching is not needed for the confirmed setup.
- ROM patching is not needed at all for the confirmed WiiLink WFC connection.
- Correct DNS routing is the essential requirement.

## Why Windows NRPT affects melonPrimeDS

melonPrimeDS inherits the melonDS SLIRP networking path.

Relevant upstream file:

https://github.com/melonDS-emu/melonDS/blob/master/src/net/Net_Slirp.cpp

The DNS handler receives the DS DNS request, extracts the domain, and calls the host resolver:

```cpp
getaddrinfo(domainname, "0", &dns_hint, &dns_res)
```

The same behavior was confirmed in melonPrimeDS.

On Windows this means the DS DNS query ultimately goes through the Windows name-resolution path. As a result, a Windows NRPT rule can redirect only the relevant namespace without changing the DNS server for the entire machine.

Conceptually:

```text
Nintendo DS game
    -> melonPrimeDS SLIRP DNS handler
    -> Windows getaddrinfo()
    -> Windows NRPT
    -> .nintendowifi.net uses 5.161.56.11
    -> WiiLink WFC DNS response
    -> WiiLink WFC service
```

## Why a hosts file entry is not equivalent

This is incorrect for the desired behavior:

```text
5.161.56.11 nintendowifi.net
```

A hosts entry means:

```text
nintendowifi.net itself has IP address 5.161.56.11
```

But `5.161.56.11` is the DNS server, not the service IP that should be used for every Nintendo WFC hostname.

The requirement is conditional DNS forwarding/resolution, not static hostname-to-IP mapping. NRPT is appropriate because it tells Windows which DNS server to use for a namespace.

## Validation commands

Check the effective rule:

```powershell
Get-DnsClientNrptPolicy -Effective |
    Where-Object { $_.Namespace -match "nintendowifi" }
```

Expected namespace/name server:

```text
Namespace   : .nintendowifi.net
NameServers : 5.161.56.11
```

Check normal resolution:

```powershell
Resolve-DnsName nas.nintendowifi.net -Type A
```

Check WiiLink DNS directly:

```powershell
Resolve-DnsName nas.nintendowifi.net -Type A -Server 5.161.56.11
```

The normal lookup and the direct WiiLink lookup should resolve consistently while the NRPT rule is active.

Clear cached DNS answers when changing the rule:

```powershell
Clear-DnsClientCache
```

or:

```text
ipconfig /flushdns
```

A full Windows reboot is normally not required.

## WiiLink-side references

Official WiiLink repositories used during the investigation:

- WiiLink Wii WFC patcher:
  https://github.com/WiiLink24/wfc-patcher-wii
- WiiLink WFC server:
  https://github.com/WiiLink24/wfc-server
- WiiLink production deployment:
  https://github.com/WiiLink24/production-deployment

The WiiLink Wii patcher now uses `wiilink.ca`, but its implementation is substantially more than a Nintendo DS `nintendowifi.net -> wiilink.ca` string replacement. It contains Wii-specific runtime patching and should not be used as evidence that AdmiralCurtiss WfcPatcher should use `--domain wiilink.ca` for DS ROMs.

## Scope and caveats

The end-to-end result in this document was confirmed with Metroid Prime Hunters on melonPrimeDS under Windows.

WiiLink's normal console setup points the console DNS at the WiiLink DNS server for all DNS queries. This repository's Windows NRPT helper is intentionally narrower: it forwards only `.nintendowifi.net` through WiiLink DNS.

That narrower rule is confirmed to work for the tested setup. A different DS title that depends on additional unrelated namespaces could require additional routing rules. Do not add extra namespaces without evidence from the affected title or packet/DNS logs.

The NRPT rule is system-wide for Windows while enabled, so `disable_WiiLink_WFC.bat` is provided to restore normal DNS behavior.

## Current repository policy

For WiiLink WFC:

```text
Use original ROM
+ enable_WiiLink_WFC.bat
```

Do not ship or recommend:

```text
--domain wiilink24.com
--domain wiilink.ca
```

for the current WiiLink DS setup.

For Wiimmfi, the existing WfcPatcher-based ROM patch workflow remains separate and is kept in this repository.
