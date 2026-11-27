#!/bin/bash
# Usage: set-icon.sh <name>   (name = file in ~/.config/open-avd/icons without .icns)
ICONS="$HOME/.config/open-avd/icons"
APP="$HOME/Applications/Open AVD.app"
name=$1
if [[ -z $name || ! -f "$ICONS/$name.icns" ]]; then
  echo "Usage: $0 <name>"; echo "Available:"; ls "$ICONS" | sed -n 's/\.icns$//p' | sed 's/^/  /'; exit 1
fi
cp "$ICONS/$name.icns" "$APP/Contents/Resources/AppIcon.icns"
codesign --force --deep -s - "$APP" 2>/dev/null
touch "$APP"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP"
killall Dock
echo "Icon -> $name"
