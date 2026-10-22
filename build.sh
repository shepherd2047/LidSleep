#!/bin/zsh
# Build a universal (arm64 + x86_64, macOS 13+) app bundle; default ~/Applications/LidSleep.app
set -e
cd "$(dirname "$0")"
APP=${1:-~/Applications/LidSleep.app}
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS"
OBJ=$(mktemp -d)
for arch in arm64 x86_64; do
  swiftc -O -target $arch-apple-macos13 main.swift -o "$OBJ/$arch"
done
lipo -create "$OBJ/arm64" "$OBJ/x86_64" -output "$APP/Contents/MacOS/LidSleep"
rm -rf "$OBJ"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>local.m.LidSleep</string>
<key>CFBundleName</key><string>LidSleep</string>
<key>CFBundleExecutable</key><string>LidSleep</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign -s - --force "$APP"
echo "built $APP"
