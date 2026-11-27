#!/bin/bash
# Build, zip and publish a new Open AVD release.
# Usage: ./release.sh <version> ["release notes"]    e.g. ./release.sh 1.2.0 "Add cold boot option"
set -euo pipefail
v=${1:?Usage: ./release.sh <version> [\"release notes\"]}
notes=${2:-"Open AVD v$v"}
cd "$(dirname "$0")"

APP="$HOME/Applications/Open AVD.app"
python3 src/make_app.py "$v"
codesign --force --deep -s - "$APP"
zip="$(mktemp -d)/Open-AVD.zip"
ditto -c -k --keepParent "$APP" "$zip"

git add -A
git diff --cached --quiet || git commit -q -m "release: v$v"
git push -q
gh release create "v$v" "$zip" --title "Open AVD v$v" --notes "$notes"
echo "Released v$v. Users get the update prompt next time they open the app."
