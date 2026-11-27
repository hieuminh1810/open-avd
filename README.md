# Open AVD

A small macOS Dock app (Automator) that lists your Android emulators (AVDs) and starts the one you pick.

- Shows a readable name, Android version, API level, Play Store, and which emulator is already running
- Remembers the last AVD you opened
- Starts emulators with a fixed DNS (`8.8.8.8, 1.1.1.1`) so a Wi-Fi change doesn't break their network
- "🔄 Sửa mạng emulator" toggles airplane mode on all running emulators to reconnect them

## Install

1. Download `Open-AVD.zip` from the latest release, unzip it, and move `Open AVD.app` to **Applications**.
2. First launch: macOS blocks it (the app is not notarized). Open **System Settings → Privacy & Security** and click **Open Anyway**, or run:
   `xattr -dr com.apple.quarantine "/Applications/Open AVD.app"`
3. Drag the app to the Dock.

Requires Android Studio with the SDK at `~/Library/Android/sdk` and at least one AVD.

## Build

```sh
cd src && python3 make_app.py          # builds ~/Applications/Open AVD.app
codesign --force --deep -s - ~/Applications/"Open AVD.app"
ditto -c -k --keepParent ~/Applications/"Open AVD.app" Open-AVD.zip
```

Change the icon: `./set-icon.sh <name>` (icons live in `icons/`).
