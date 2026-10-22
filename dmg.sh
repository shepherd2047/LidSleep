#!/bin/zsh
# Package LidSleep.app into dist/LidSleep.dmg (drag-to-Applications layout)
set -e
cd "$(dirname "$0")"
STAGE=$(mktemp -d)
./build.sh "$STAGE/LidSleep.app"
ln -s /Applications "$STAGE/Applications"
mkdir -p dist; rm -f dist/LidSleep.dmg
hdiutil create -volname LidSleep -srcfolder "$STAGE" -fs HFS+ -format UDZO -ov dist/LidSleep.dmg >/dev/null
rm -rf "$STAGE"
echo "built dist/LidSleep.dmg"
