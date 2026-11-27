#!/bin/bash
# Toggle airplane mode on every running emulator so it reconnects. Prints how many were fixed.
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
devices=$("$ADB" devices 2>/dev/null | awk '/^emulator-/ && $2=="device"{print $1}')
[[ -z $devices ]] && { echo 0; exit 0; }
for s in $devices; do "$ADB" -s "$s" shell cmd connectivity airplane-mode enable >/dev/null 2>&1; done
sleep 2
for s in $devices; do "$ADB" -s "$s" shell cmd connectivity airplane-mode disable >/dev/null 2>&1; done
echo "$devices" | wc -l | tr -d ' '
