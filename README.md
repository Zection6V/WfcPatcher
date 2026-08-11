# Nintendo DS WFC helper

This repository contains simple Windows helpers for Nintendo DS online services.

## Recommended DNS-routing helpers

The current helpers use Windows NRPT so only `*.nintendowifi.net` is resolved through the selected replacement-service DNS server. The PC's global DNS setting is not changed, and ROM patching is not required for the confirmed WiiLink setup.

### Scripts

```text
enable_WiiLink_WFC.bat
enable_Wiimmfi_WFC.bat
show_WFC_DNS_status.bat
remove_WFC_DNS_routing.bat
```

The two enable scripts are mutually exclusive. Enabling WiiLink removes the repository-managed Wiimmfi rule first, and enabling Wiimmfi removes the repository-managed WiiLink rule first.

**To switch servers, just run the enable script for the server you want to use.**

### WiiLink WFC

```text
Namespace:   .nintendowifi.net
DNS server:  5.161.56.11
```

For melonPrimeDS + Metroid Prime Hunters, an original/unmodified ROM was confirmed to connect successfully. NoSSL patching and `--domain wiilink.ca` are not required.

### Wiimmfi / Kaeru WFC

```text
Namespace:   .nintendowifi.net
DNS server:  178.62.43.212
```

### Important when switching between WFC servers: error 60000

Nintendo DS WFC user information is tied to the server/profile state stored by the game/system. If you first connect to one replacement server (for example WiiLink) and then switch DNS routing to another server (for example Wiimmfi), attempting to reuse the existing WFC user information may result in error `60000`.

If error `60000` appears after changing servers:

1. Open the Nintendo DS Wi-Fi Connection settings.
2. Delete the existing WFC user information/profile.
3. Connect again so new WFC user information is created for the newly selected server.

If you want to switch between servers frequently without recreating the WFC user information every time, keep separate emulator data folders / emulator copies for each server so each environment retains its own WFC user information.

Changing the NRPT DNS rule and changing the DS WFC user profile are separate operations.

### Status check

Run:

```text
show_WFC_DNS_status.bat
```

It displays:

- which repository-managed WFC service is active
- NRPT namespace
- configured DNS server
- current IPv4 resolution for `nas.nintendowifi.net`

### Restore normal DNS

Run:

```text
remove_WFC_DNS_routing.bat
```

It removes both repository-managed WiiLink/Wiimmfi NRPT rules and clears the Windows DNS cache.

The leading `.` in `.nintendowifi.net` is important: it makes the rule apply to subdomains such as `nas.nintendowifi.net`.

## Legacy Wiimmfi ROM patching

The original drag-and-drop helper is kept for compatibility:

```text
dragAndDropNdsFileToThisBatFile_wiimmfi_de.bat
```

The included `WfcPatcher.exe` is based on AdmiralCurtiss/WfcPatcher v1.6:
https://github.com/AdmiralCurtiss/WfcPatcher/releases/tag/v1.6

## Technical notes

- [`docs/WIILINK_WFC_DNS_INVESTIGATION.md`](docs/WIILINK_WFC_DNS_INVESTIGATION.md)
- [`docs/WIIMMFI_WFC_DNS.md`](docs/WIIMMFI_WFC_DNS.md)
- [`docs/WFC_DNS_ROUTING_AND_SWITCHING.md`](docs/WFC_DNS_ROUTING_AND_SWITCHING.md)
- [`docs/WFC_DNS_SWITCH_TEST_CHECKLIST.md`](docs/WFC_DNS_SWITCH_TEST_CHECKLIST.md)

---

# Nintendo DS WFC 接続ヘルパー

このリポジトリには Nintendo DS のオンラインサービスへ接続するための Windows 向けヘルパーを置いています。

## 推奨: NRPTによるDNSルーティング

Windows の NRPT を使い、`*.nintendowifi.net` の名前解決だけを選択したサービスのDNSへ送ります。PC全体のDNS設定は変更しません。確認済みのWiiLink構成ではROMパッチも不要です。

### 使用するバッチ

```text
enable_WiiLink_WFC.bat
enable_Wiimmfi_WFC.bat
show_WFC_DNS_status.bat
remove_WFC_DNS_routing.bat
```

WiiLinkとWiimmfiの有効化バッチは排他的に動作します。WiiLinkを有効にするとWiimmfi用ルールを削除してからWiiLinkを設定し、Wiimmfiを有効にするとWiiLink用ルールを削除してからWiimmfiを設定します。

**サーバーを切り替える場合は、使いたい方の enable バッチを実行するだけです。**

### WiiLink WFC

```text
Namespace:   .nintendowifi.net
DNS server:  5.161.56.11
```

melonPrimeDS + Metroid Prime Hunters では、未改変のオリジナルROMで接続確認済みです。NoSSLパッチも `--domain wiilink.ca` も不要です。

### Wiimmfi / Kaeru WFC

```text
Namespace:   .nintendowifi.net
DNS server:  178.62.43.212
```

### サーバー切り替え時の注意: エラー60000

たとえば一度WiiLinkへ接続したあと、そのDSのWFCユーザー情報をそのまま使ってWiimmfiなど別のWFCサーバーへ接続しようとすると、エラー `60000` が出る場合があります。

別のサーバーへ変更したあとに `60000` が出た場合は、DSの「Wi-Fi Connection設定」から既存のWFCユーザー情報を削除し、新しく選択したサーバー用のWFCユーザー情報を作り直してください。

WiiLinkとWiimmfiなど複数のサーバーを頻繁に切り替えたい場合は、エミュレータのデータフォルダやエミュレータ本体のフォルダをサーバーごとに分け、それぞれの環境でWFCユーザー情報を保持しておく方法もあります。

**NRPTによる接続先DNSの切り替えと、DS側のWFCユーザー情報の切り替えは別の処理です。**

### 現在の状態確認

```text
show_WFC_DNS_status.bat
```

で、現在有効なサービス、NRPT namespace、DNS server、`nas.nintendowifi.net` のIPv4解決結果を確認できます。

### 通常DNSへ戻す

```text
remove_WFC_DNS_routing.bat
```

このリポジトリが作成したWiiLink/Wiimmfi用NRPTルールをまとめて削除し、WindowsのDNSキャッシュをクリアします。

`.nintendowifi.net` の先頭の `.` は重要です。これにより `nas.nintendowifi.net` などのサブドメインにも適用されます。

## 従来のWiimmfi ROMパッチ

互換用として従来のバッチも残しています。

```text
dragAndDropNdsFileToThisBatFile_wiimmfi_de.bat
```

同梱の `WfcPatcher.exe` は AdmiralCurtiss/WfcPatcher v1.6 を使用しています。
https://github.com/AdmiralCurtiss/WfcPatcher/releases/tag/v1.6

## 調査ナレッジ

- [`docs/WIILINK_WFC_DNS_INVESTIGATION.md`](docs/WIILINK_WFC_DNS_INVESTIGATION.md)
- [`docs/WIIMMFI_WFC_DNS.md`](docs/WIIMMFI_WFC_DNS.md)
- [`docs/WFC_DNS_ROUTING_AND_SWITCHING.md`](docs/WFC_DNS_ROUTING_AND_SWITCHING.md)
- [`docs/WFC_DNS_SWITCH_TEST_CHECKLIST.md`](docs/WFC_DNS_SWITCH_TEST_CHECKLIST.md)
