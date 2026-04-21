# claude-notice

WSL2 上で動く Claude Code から、ホスト Windows にトースト通知を表示するための設定集です。
応答完了・権限確認待ち・アイドル状態を [BurntToast](https://github.com/Windos/BurntToast) でサイレント通知します。

## 通知されるイベント

`.claude/settings.json` の hooks で以下を購読しています。

| イベント | 通知メッセージ | 用途 |
| --- | --- | --- |
| `Stop` | 応答完了 | Claude の応答が完了したとき |
| `Notification` (`permission_prompt`) | ツール実行の承認待ち | ツール実行の承認が必要なとき |
| `Notification` (`idle_prompt`) | アイドル中（入力待ち） | 入力待ちでアイドル状態になったとき |

すべて `-Silent` 指定で、音は鳴らさず通知センターに表示します。

## 必要環境

- Windows 上の WSL2 で動く Claude Code
- ホスト Windows に PowerShell モジュール [BurntToast](https://www.powershellgallery.com/packages/BurntToast) がインストール済み

BurntToast のインストール（Windows 側 PowerShell）:

```powershell
Install-Module -Name BurntToast -Scope CurrentUser
```

## 使い方

このリポジトリを Claude Code のプロジェクトとして開けば、`.claude/settings.json` が自動で読み込まれ、hooks が有効になります。

ユーザー全体に適用したい場合は `.claude/settings.json` の内容を `~/.claude/settings.json` にマージしてください。

## 仕組み

各 hook は WSL から `powershell.exe` を呼び出して BurntToast を実行します。サードパーティモジュールを安定して動かすため、以下を明示的に指定しています。

- `-ExecutionPolicy Bypass` — モジュール読み込みのポリシー回避
- `Import-Module BurntToast` — モジュールの明示ロード
- `async: true` — Claude Code 側を待たせずに通知を投げる

## ファイル構成

```
.
├── .claude/
│   └── settings.json   # Claude Code の hooks 設定
└── README.md
```
