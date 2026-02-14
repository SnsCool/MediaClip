#!/bin/bash
set -e

cd "$(dirname "$0")"

VERSION="${1:-1.0.0}"
echo "=== MediaClip v${VERSION} Release Build ==="

# 1. Build optimized binary
echo "[1/4] Building release binary..."
swift build -c release

# 2. Create app bundle
echo "[2/4] Creating app bundle..."
APP_DIR="build/MediaClip.app/Contents"
rm -rf build/MediaClip.app
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"

cp .build/release/MediaClip "$APP_DIR/MacOS/MediaClip"

cat > "$APP_DIR/Info.plist" << PLIST
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
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
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

# 3. Create DMG
echo "[3/4] Creating DMG..."
DMG_NAME="MediaClip-v${VERSION}.dmg"
rm -rf build/dmg_staging
mkdir -p build/dmg_staging
cp -R build/MediaClip.app build/dmg_staging/
ln -s /Applications build/dmg_staging/Applications

rm -f "build/${DMG_NAME}"
hdiutil create \
    -volname "MediaClip" \
    -srcfolder build/dmg_staging \
    -ov \
    -format UDZO \
    "build/${DMG_NAME}"

rm -rf build/dmg_staging

# 4. Done
echo "[4/4] Done!"
echo ""
echo "Output: build/${DMG_NAME}"
echo "Size: $(du -h "build/${DMG_NAME}" | cut -f1)"
echo ""
echo "To create a GitHub release:"
echo "  gh release create v${VERSION} build/${DMG_NAME} --title \"MediaClip v${VERSION}\" --notes-file RELEASE_NOTES.md"
