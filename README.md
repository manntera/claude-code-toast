# claude-code-toast

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

WSL2 上で動く Claude Code から、ホスト Windows にトースト通知を出す Claude Code プラグインです。
応答完了・承認待ち・エラー停止などを [BurntToast](https://github.com/Windos/BurntToast) でサイレント通知し、
イベントごとに任意の wav を鳴らし分けられます。

「AI の応答が終わったこと」だけでなく、**承認待ちやエラーで処理が止まっていることに気づけない問題**を解消するのが目的です。

## 通知されるイベント

| イベント | 通知メッセージ | サウンドキー | 発火タイミング |
| --- | --- | --- | --- |
| `SessionStart` | セッション開始 | `start` | セッションの開始・再開 |
| `Stop` | 応答完了 | `ok` | Claude の応答が完了した |
| `StopFailure` | エラーで停止 | `error` | API エラーでターンが終了した（このとき `Stop` は発火しない） |
| `PermissionDenied` | ツール実行が拒否された | `no` | auto mode がツール実行を拒否した |
| `PreCompact` | コンテキストを圧縮中 | `clean` | コンテキスト圧縮の直前 |
| `SessionEnd` | セッション終了 | `end` | セッションの終了 |
| `Notification` (`permission_prompt`) | ツール実行の承認待ち | `halt` | ツール実行の承認を求めて停止した |
| `Notification` (`agent_needs_input`) | エージェントが入力待ち | `info` | サブエージェント／チームメイトが入力を求めた |
| `Notification` (`elicitation_dialog`) | MCP が入力待ち | `notice` | MCP サーバーが入力を求めた |
| `Notification` (`elicitation_url_dialog`) | MCP が URL 認証待ち | `warn` | MCP サーバーが URL を開いての認証を求めた |

トーストはすべて `-Silent` 指定です。音は BurntToast ではなくプラグイン側で鳴らすため、**サウンドを設定しなければ通知音は一切鳴りません**。

`PostToolUseFailure` や `SubagentStop` はツール実行のたびに発火して過剰になるため、あえて購読していません。必要なら `hooks/hooks.json` に追加してください。

## 必要環境

- Windows 上の WSL2 で動く Claude Code
- ホスト Windows に PowerShell モジュール [BurntToast](https://www.powershellgallery.com/packages/BurntToast) がインストール済み

## セットアップ

### 1. BurntToast を入れる（Windows 側で一度だけ）

WSL 側からは自動でインストールできません。Windows のスタートメニューから「Windows PowerShell」を起動して実行してください。

```powershell
Install-Module -Name BurntToast -Scope CurrentUser -Force
```

初回は NuGet プロバイダーのインストール確認が出るので `Y` で進めます。次のワンライナーでテスト通知が出れば成功です。

```powershell
Import-Module BurntToast; New-BurntToastNotification -Text 'Claude Code', 'セットアップ完了' -Silent
```

> **注意:** PowerShell 7（`pwsh`）ではなく、Windows 標準の **Windows PowerShell（`powershell.exe`）** を使ってください。プラグインは `powershell.exe` を呼び出します。

### 2. プラグインを入れる

```
/plugin marketplace add manntera/claude-code-toast
/plugin install claude-code-toast@wsl-notify-tools
```

これだけでトースト通知が有効になります。`~/.claude/settings.json` の既存設定（`permissions` や `model` など）には触れません。

### 3. サウンドを設定する（任意）

`~/.claude/notify-toast.conf` を作り、サウンドの置き場と、キーごとの wav ファイル名を書きます。
このファイルはプラグインに含まれません。**どの音を使うかは各自の環境に閉じます。**

```sh
# ~/.claude/notify-toast.conf
# VOICE_DIR には %USERPROFILE% などの Windows 環境変数を書ける
VOICE_DIR='%WINDIR%\Media'

VOICE_ok='Windows Notify System Generic.wav'
VOICE_error='Windows Critical Stop.wav'
VOICE_halt='Windows Notify Messaging.wav'
```

- 書いたキーだけ音が鳴ります。未設定のキーはトーストのみです
- パスは PowerShell の `ExpandEnvironmentVariables` で展開されるため、**Windows のユーザー名が違う PC でもこのファイルをそのまま持ち回れます**
- 別の場所に置きたい場合は環境変数 `CLAUDE_TOAST_CONF` でパスを指定できます

サウンドファイルを配布物に含める場合は、その音源のライセンスを必ず確認してください。
**このリポジトリには音源を一切同梱していません。**

## 動作確認

プラグインのスクリプトは単体でも実行できます。

```sh
~/.claude/plugins/*/claude-code-toast/scripts/notify-toast.sh '確認' ok
```

## 構成

```
.claude-plugin/marketplace.json          マーケットプレイス定義
plugins/claude-code-toast/
├── .claude-plugin/plugin.json           プラグイン定義
├── hooks/hooks.json                     どのイベントで何を通知するか
└── scripts/notify-toast.sh              トースト表示と wav 再生（音源の情報は持たない）
```

イベントと通知文言を変えたいときは `hooks/hooks.json` を、通知の出し方そのものを変えたいときは `scripts/notify-toast.sh` を編集してください。

## ライセンス

MIT License. [LICENSE](LICENSE) を参照してください。
