# Nintendo DS WFC helper

This repository contains simple Windows helpers for Nintendo DS online services.

## WiiLink WFC — current recommended method

**Do not patch the ROM with `--domain wiilink.ca`.**

For the current WiiLink WFC service, an original/unmodified NDS ROM can connect by routing DNS lookups for `*.nintendowifi.net` through the WiiLink WFC DNS server.

### Enable WiiLink WFC

1. Run `enable_WiiLink_WFC.bat`.
2. Accept the Windows administrator/UAC prompt.
3. Start the game with the original ROM. NoSSL patching is not required.

The script creates this Windows NRPT rule:

```text
Namespace:   .nintendowifi.net
DNS server:  5.161.56.11
```

The leading `.` in `.nintendowifi.net` is important because the rule must match subdomains such as `nas.nintendowifi.net`.

You can verify the active routing in PowerShell:

```powershell
Resolve-DnsName nas.nintendowifi.net -Type A
```

### Disable / restore normal DNS behavior

Run `disable_WiiLink_WFC.bat` as administrator. It removes only the NRPT rule created by the WiiLink helper and clears the Windows DNS cache.

> The WiiLink rule affects Windows DNS resolution for `*.nintendowifi.net` while enabled. It does not modify the ROM.

## Wiimmfi ROM patching

The existing Wiimmfi drag-and-drop helper is still available:

```text
dragAndDropNdsFileToThisBatFile_wiimmfi_de.bat
```

Drop an `.nds` file onto it to create a ROM patched for `wiimmfi.de`.

The included `WfcPatcher.exe` is based on AdmiralCurtiss/WfcPatcher v1.6:
https://github.com/AdmiralCurtiss/WfcPatcher/releases/tag/v1.6

## Technical notes / investigation history

See [`docs/WIILINK_WFC_DNS_INVESTIGATION.md`](docs/WIILINK_WFC_DNS_INVESTIGATION.md) for the full investigation, failed approaches, root cause, validation commands, and implementation details.

---

# Nintendo DS WFC 接続ヘルパー

このリポジトリには Nintendo DS のオンラインサービスへ接続するための Windows 向けヘルパーを置いています。

## WiiLink WFC — 現在の推奨方式

**ROMを `--domain wiilink.ca` でパッチしないでください。**

現在の WiiLink WFC は、`*.nintendowifi.net` の名前解決だけを WiiLink WFC の DNS サーバーへ送ることで、**未改変のオリジナルROMのまま接続できます**。

### WiiLink WFC を有効にする

1. `enable_WiiLink_WFC.bat` を実行します。
2. Windows の管理者/UAC確認を許可します。
3. オリジナルROMをそのまま起動します。NoSSLパッチも不要です。

バッチは Windows の NRPT に次のルールを追加します。

```text
Namespace:   .nintendowifi.net
DNS server:  5.161.56.11
```

`.nintendowifi.net` の先頭の `.` は重要です。これにより `nas.nintendowifi.net` などのサブドメインにもルールが適用されます。

PowerShell で確認できます。

```powershell
Resolve-DnsName nas.nintendowifi.net -Type A
```

### 元に戻す

`disable_WiiLink_WFC.bat` を管理者権限で実行してください。WiiLink用に作成したNRPTルールだけを削除し、WindowsのDNSキャッシュをクリアします。

> WiiLink用ルールを有効にしている間は、Windows上の `*.nintendowifi.net` の名前解決に影響します。ROM自体は変更しません。

## Wiimmfi 用ROMパッチ

Wiimmfi用の従来バッチは引き続き使用できます。

```text
dragAndDropNdsFileToThisBatFile_wiimmfi_de.bat
```

`.nds` ファイルをドラッグ＆ドロップすると `wiimmfi.de` 向けのパッチ済みROMを生成します。

同梱の `WfcPatcher.exe` は AdmiralCurtiss/WfcPatcher v1.6 を使用しています。
https://github.com/AdmiralCurtiss/WfcPatcher/releases/tag/v1.6

## 調査ナレッジ

今回の調査結果、失敗した方式、原因、検証コマンド、実装詳細は [`docs/WIILINK_WFC_DNS_INVESTIGATION.md`](docs/WIILINK_WFC_DNS_INVESTIGATION.md) にまとめています。
