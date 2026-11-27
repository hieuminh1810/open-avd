#!/bin/bash
# update.sh check <current-version>   -> prints the latest version if it is newer, else nothing
# update.sh install <app-path> [noopen] -> downloads the latest release, replaces the app, reopens it
REPO=hieuminh1810/open-avd
num() { echo "$1" | awk -F. '{printf "%d%03d%03d\n", $1, $2, $3}'; }

case $1 in
check)
  latest=$(curl -fsS -m 2 "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null |
    sed -nE 's/.*"tag_name": *"v?([^"]+)".*/\1/p' | head -1)
  [[ -n $latest && $(num "$latest") -gt $(num "$2") ]] && echo "$latest"
  exit 0
  ;;
install)
  app=$2
  tmp=$(mktemp -d)
  sleep 1 # let the running app quit first
  if curl -fsSL -m 120 -o "$tmp/app.zip" "https://github.com/$REPO/releases/latest/download/Open-AVD.zip" &&
    ditto -x -k "$tmp/app.zip" "$tmp/new" && [[ -d "$tmp/new/Open AVD.app" ]] &&
    mv "$app" "$tmp/old"; then
    if ditto "$tmp/new/Open AVD.app" "$app"; then
      xattr -dr com.apple.quarantine "$app" 2>/dev/null
      touch "$app"
      [[ $3 != noopen ]] && open "$app"
    else
      mv "$tmp/old" "$app"
      osascript -e 'display alert "Open AVD" message "Cập nhật thất bại, vẫn giữ bản cũ."'
    fi
  else
    osascript -e 'display alert "Open AVD" message "Không tải được bản mới. Kiểm tra mạng rồi thử lại."'
  fi
  rm -rf "$tmp"
  ;;
esac
