#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Building MediaClip..."
swift build

echo "Creating app bundle..."
APP_DIR="build/MediaClip.app/Contents"
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"

cp .build/debug/MediaClip "$APP_DIR/MacOS/MediaClip"
# Write resolved Info.plist (no Xcode build variables)
cat > "$APP_DIR/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>MediaClip</string>
    <key>CFBundleDisplayName</key>
    <string>MediaClip</string>
    <key>CFBundleIdentifier</key>
    <string>com.mediaclip.app</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>MediaClip</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

echo "Build complete! App bundle at: build/MediaClip.app"
echo ""
echo "To run: open build/MediaClip.app"
echo "Note: Grant Accessibility permission in System Settings > Privacy & Security > Accessibility"
