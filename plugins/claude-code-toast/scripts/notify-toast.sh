#!/bin/sh
# WSL2 から ホスト Windows へトースト通知を出し、任意で wav を再生する。
#   usage: notify-toast.sh <本文> [ボイスキー]
#
# このスクリプトは音源の情報を一切持たない。どのキーにどの wav を割り当てるかは
# 設定ファイル側（既定 ~/.claude/notify-toast.conf）で指定する。
# 設定が無い、またはキーに対応する wav が無い場合は、音を鳴らさずトーストだけ出す。
#
# 設定ファイルの書式:
#   VOICE_DIR='%USERPROFILE%\path\to\sounds'   # Windows 環境変数を使ってよい
#   VOICE_<キー>='ファイル名.wav'
#
# 前提: ホスト Windows に PowerShell モジュール BurntToast が入っていること
#   Install-Module -Name BurntToast -Scope CurrentUser -Force

msg=${1:-通知}
key=${2:-}

conf=${CLAUDE_TOAST_CONF:-$HOME/.claude/notify-toast.conf}
if [ -f "$conf" ]; then
    . "$conf"
fi

# キーは変数名の一部として使うため、英数字とアンダースコアだけを許可する
case "$key" in
    *[!A-Za-z0-9_]*) key= ;;
esac

wav=
if [ -n "$key" ] && [ -n "${VOICE_DIR:-}" ]; then
    wav_file=$(eval "printf '%s' \"\${VOICE_${key}:-}\"")
    if [ -n "$wav_file" ]; then
        wav="${VOICE_DIR}\\${wav_file}"
    fi
fi

# PowerShell のシングルクォート文字列では ' を '' でエスケープする
psq() {
    printf '%s' "$1" | sed "s/'/''/g"
}

ps_cmd="Import-Module BurntToast; New-BurntToastNotification -Text 'Claude Code', '$(psq "$msg")' -Silent"
if [ -n "$wav" ]; then
    # %USERPROFILE% 等の展開は PowerShell 側に任せる（PC ごとの差を吸収する）
    ps_cmd="$ps_cmd; (New-Object Media.SoundPlayer ([Environment]::ExpandEnvironmentVariables('$(psq "$wav")'))).PlaySync()"
fi

# トーストと再生を 1 プロセスにまとめる（powershell.exe の起動が重いため）。
# hook は stdin に JSON を流し込んでくるが使わない。powershell.exe に渡すと
# 読み取られてしまうため切り離す。
exec powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$ps_cmd" < /dev/null
