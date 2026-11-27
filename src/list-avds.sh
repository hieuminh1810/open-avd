#!/bin/bash
# Prints one line per AVD: name|label|running(1/0)
SDK="$HOME/Library/Android/sdk"
running=$(for s in $("$SDK/platform-tools/adb" devices 2>/dev/null | awk '/^emulator-/{print $1}'); do
  "$SDK/platform-tools/adb" -s "$s" emu avd name 2>/dev/null | head -1
done | tr -d '\r')

for n in $("$SDK/emulator/emulator" -list-avds | grep -v '^INFO'); do
  cfg="$(grep '^path=' "$HOME/.android/avd/$n.ini" | cut -d= -f2-)/config.ini"
  disp=$(grep '^avd.ini.displayname=' "$cfg" | cut -d= -f2-)
  api=$(grep '^image.sysdir.1=' "$cfg" | sed -E 's#.*android-([0-9.]+)/.*#\1#')
  case ${api%%.*} in
    28) v=9 ;; 29) v=10 ;; 30) v=11 ;; 31) v=12 ;; 32) v=12L ;;
    33) v=13 ;; 34) v=14 ;; 35) v=15 ;; 36) v=16 ;; *) v="?" ;;
  esac
  play=""; grep -q '^PlayStore.enabled=true' "$cfg" && play="  ·  Play Store"
  on=0; mark=""; echo "$running" | grep -qx "$n" && on=1 && mark="   ● đang chạy"
  echo "$n|${disp:-$n}  ·  Android $v (API $api)$play$mark|$on"
done
