# Nintendo DS WFC helper

This repository contains simple Windows helpers for Nintendo DS online services.

## DNS routing helpers

The recommended Windows helpers use NRPT to route only `*.nintendowifi.net` through the selected Nintendo DS replacement-service DNS server. They do not change the DNS server for the whole PC.

### One-click service switcher

Run:

```text
switch_WFC_DNS_service.bat
```

and choose:

```text
1. WiiLink WFC   - 5.161.56.11
2. Wiimmfi       - 178.62.43.212
3. Disable all repository-managed WFC DNS routing
```

You can also run the individual scripts directly.

### WiiLink WFC

```text
enable_WiiLink_WFC.bat
```

The script configures:

```text
Namespace:   .nintendowifi.net
DNS server:  5.161.56.11
```

For the confirmed melonPrimeDS/Metroid Prime Hunters setup, an original/unmodified ROM works; NoSSL patching and `--domain wiilink.ca` are not required.

### Wiimmfi / Kaeru WFC

```text
enable_Wiimmfi_WFC.bat
```

The script configures:

```text
Namespace:   .nintendowifi.net
DNS server:  178.62.43.212
```

`178.62.43.212` is used as the Nintendo DS DNS endpoint for the Wiimmfi/Kaeru WFC path.

### Switch between WiiLink and Wiimmfi

The two enable scripts are mutually exclusive:

- `enable_WiiLink_WFC.bat` removes this repository's Wiimmfi NRPT rule before enabling WiiLink.
- `enable_Wiimmfi_WFC.bat` removes this repository's WiiLink NRPT rule before enabling Wiimmfi.

So switching services is just a matter of running the other enable script, or using `switch_WFC_DNS_service.bat`.

### Disable DNS routing

Individual removal:

```text
disable_WiiLink_WFC.bat
disable_Wiimmfi_WFC.bat
```

Remove both helper rules and restore normal Windows DNS behavior:

```text
disable_all_WFC_DNS_routing.bat
```

All scripts request administrator privileges automatically and clear the Windows DNS cache after changing NRPT.

The leading `.` in `.nintendowifi.net` is important because the rule must match subdomains such as `nas.nintendowifi.net`.

You can verify the active resolution in PowerShell:

```powershell
Get-DnsClientNrptPolicy -Effective | Where-Object { $_.Namespace -match "nintendowifi" }
Resolve-DnsName nas.nintendowifi.net -Type A
```

## Legacy Wiimmfi ROM patching

The existing drag-and-drop helper is kept for compatibility:

```text
dragAndDropNdsFileToThisBatFile_wiimmfi_de.bat
```

Drop an `.nds` file onto it to create a ROM patched for `wiimmfi.de`.

The included `WfcPatcher.exe` is based on AdmiralCurtiss/WfcPatcher v1.6:
https://github.com/AdmiralCurtiss/WfcPatcher/releases/tag/v1.6

## Technical notes

- [`docs/WIILINK_WFC_DNS_INVESTIGATION.md`](docs/WIILINK_WFC_DNS_INVESTIGATION.md)
- [`docs/WIIMMFI_WFC_DNS.md`](docs/WIIMMFI_WFC_DNS.md)
- [`docs/WFC_DNS_ROUTING_AND_SWITCHING.md`](docs/WFC_DNS_ROUTING_AND_SWITCHING.md)

---

# Nintendo DS WFC 接続ヘルパー

このリポジトリには Nintendo DS のオンラインサービスへ接続するための Windows 向けヘルパーを置いています。

## DNSルーティング方式

Windows の NRPT を使い、`*.nintendowifi.net` の名前解決だけを選択したサービスのDNSへ送ります。PC全体のDNSサーバー設定を変更する方式ではありません。

### ワンクリック切り替え

```text
switch_WFC_DNS_service.bat
```

を実行すると、次から選択できます。

```text
1. WiiLink WFC   - 5.161.56.11
2. Wiimmfi       - 178.62.43.212
3. このリポジトリが管理するWFC DNSルールをすべて解除
```

個別のバッチを直接実行しても構いません。

### WiiLink WFC

```text
enable_WiiLink_WFC.bat
```

設定内容:

```text
Namespace:   .nintendowifi.net
DNS server:  5.161.56.11
```

melonPrimeDS + Metroid Prime Hunters では、未改変のオリジナルROMで接続確認済みです。NoSSLパッチも `--domain wiilink.ca` も不要です。

### Wiimmfi / Kaeru WFC

```text
enable_Wiimmfi_WFC.bat
```

設定内容:

```text
Namespace:   .nintendowifi.net
DNS server:  178.62.43.212
```

`178.62.43.212` を DS 向け Wiimmfi / Kaeru WFC のDNSとして使用します。

### WiiLink と Wiimmfi の相互切り替え

2つの有効化バッチは排他的に動作します。

- `enable_WiiLink_WFC.bat` は、このリポジトリが作成したWiimmfi用ルールを削除してからWiiLinkを有効化します。
- `enable_Wiimmfi_WFC.bat` は、このリポジトリが作成したWiiLink用ルールを削除してからWiimmfiを有効化します。

そのため、**使いたい方の enable バッチを実行するだけで切り替え可能**です。`switch_WFC_DNS_service.bat` から選択することもできます。

### 元に戻す

個別解除:

```text
disable_WiiLink_WFC.bat
disable_Wiimmfi_WFC.bat
```

両方まとめて解除:

```text
disable_all_WFC_DNS_routing.bat
```

各バッチは必要に応じて管理者権限を自動要求し、NRPT変更後にWindowsのDNSキャッシュをクリアします。

`.nintendowifi.net` の先頭の `.` は重要です。これにより `nas.nintendowifi.net` などのサブドメインにもルールが適用されます。

確認コマンド:

```powershell
Get-DnsClientNrptPolicy -Effective | Where-Object { $_.Namespace -match "nintendowifi" }
Resolve-DnsName nas.nintendowifi.net -Type A
```

## 従来のWiimmfi ROMパッチ

従来のドラッグ＆ドロップ用バッチも互換用として残しています。

```text
dragAndDropNdsFileToThisBatFile_wiimmfi_de.bat
```

同梱の `WfcPatcher.exe` は AdmiralCurtiss/WfcPatcher v1.6 を使用しています。
https://github.com/AdmiralCurtiss/WfcPatcher/releases/tag/v1.6

## 調査ナレッジ

- [`docs/WIILINK_WFC_DNS_INVESTIGATION.md`](docs/WIILINK_WFC_DNS_INVESTIGATION.md)
- [`docs/WIIMMFI_WFC_DNS.md`](docs/WIIMMFI_WFC_DNS.md)
- [`docs/WFC_DNS_ROUTING_AND_SWITCHING.md`](docs/WFC_DNS_ROUTING_AND_SWITCHING.md)
