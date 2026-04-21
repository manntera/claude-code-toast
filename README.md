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

## 使う前にやること（初回セットアップ）

このプロジェクトを使い始める前に、**Windows 側で一度だけ** BurntToast のインストールを行ってください。WSL 側からは自動でインストールできないため、必ず Windows のスタートメニューから「Windows PowerShell」を起動して実行します。

1. Windows PowerShell を開く（管理者権限は不要）
2. 次のコマンドを実行する

   ```powershell
   Install-Module -Name BurntToast -Scope CurrentUser -Force
   ```

3. 初回実行時は次のような **NuGet プロバイダーのインストール確認** が表示されます。`Y` を入力して進めてください。

   ```text
   続行するには NuGet プロバイダーが必要です
   PowerShellGet で NuGet ベースのリポジトリを操作するには、'2.8.5.201' 以降のバージョンの
   NuGet プロバイダーが必要です。…
   今すぐ PowerShellGet で NuGet プロバイダーをインストールしてインポートしますか?
   [Y] はい(Y)  [N] いいえ(N)  [S] 中断(S)  [?] ヘルプ (既定値は "Y"): Y
   ```

4. プロンプトが戻ってきたら完了です。動作確認は以下のワンライナーで行えます。テスト通知が表示されれば成功です。

   ```powershell
   Import-Module BurntToast; New-BurntToastNotification -Text 'Claude Code', 'セットアップ完了' -Silent
   ```

> **注意:** PowerShell 7（`pwsh`）ではなく、Windows 標準の **Windows PowerShell（`powershell.exe`）** で実行してください。`.claude/settings.json` の hooks は `powershell.exe` を呼び出します。

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
