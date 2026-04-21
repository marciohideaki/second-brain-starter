#!/bin/bash
# Hook: Notification
# Fires when a long-running Claude Code operation finishes.
# Emits a visual/audio signal.
#
# Registered in ~/.claude/settings.json by install.sh:
#   "Notification": [{ "hooks": [{ "type": "command",
#     "command": "bash {VAULT}/_bootstrap/global/hooks/on-notification.sh", "timeout": 5 }] }]
#
# Platform behavior:
#   Windows (WSL): PowerShell toast notification
#   Linux / macOS: terminal bell

MSG="${1:-Operation complete}"

# Try Windows toast via WSL
if command -v powershell.exe &>/dev/null; then
  powershell.exe -Command "
    Add-Type -AssemblyName System.Windows.Forms
    \$notify = New-Object System.Windows.Forms.NotifyIcon
    \$notify.Icon = [System.Drawing.SystemIcons]::Information
    \$notify.BalloonTipTitle = 'Claude Code'
    \$notify.BalloonTipText = '$MSG'
    \$notify.Visible = \$true
    \$notify.ShowBalloonTip(3000)
    Start-Sleep -Milliseconds 3500
    \$notify.Dispose()
  " 2>/dev/null
  exit 0
fi

# Fallback: terminal bell
printf '\a'
exit 0
