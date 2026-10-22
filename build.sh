#!/bin/zsh
# Build and bundle into ~/Applications/LidSleep.app
set -e
cd "$(dirname "$0")"
APP=~/Applications/LidSleep.app
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS"
swiftc -O main.swift -o "$APP/Contents/MacOS/LidSleep"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>local.m.LidSleep</string>
<key>CFBundleName</key><string>LidSleep</string>
<key>CFBundleExecutable</key><string>LidSleep</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign -s - --force "$APP"
echo "built $APP"
