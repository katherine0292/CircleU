#!/bin/bash
set -euo pipefail

prototype_root="$(cd "$(dirname "$0")/.." && pwd)"
developer_path="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR="$developer_path"
swift_path="$developer_path/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc"
sdk_path="$(xcrun --sdk iphonesimulator --show-sdk-path)"
app_path="${CIRCLEU_MOTION_SIM_APP_PATH:-/tmp/CircleU Motion Simulator.app}"
module_cache="${CIRCLEU_MOTION_SIM_CACHE:-/tmp/circleu-motion-simulator-cache}"
source_root="$prototype_root/Sources/CircleUVisualPrototype"

mkdir -p "$app_path" "$module_cache"
"$swift_path" -parse-as-library -swift-version 6 -module-name CircleUMotionSimulator \
    -sdk "$sdk_path" -target arm64-apple-ios17.0-simulator -module-cache-path "$module_cache" \
    "$source_root/BrandDemo.swift" "$source_root/BrandMotionDemo.swift" \
    "$prototype_root/SimulatorHost/CircleUMotionSimulatorApp.swift" \
    -o "$app_path/CircleUMotionSimulator"
cp "$source_root/Resources/BrandArtwork/BrandLogo.png" "$app_path/"
cp "$source_root/Resources/BrandArtwork/Expansion01/PinguWelcomeV1.png" "$app_path/"
cp "$source_root/Resources/BrandFonts/PlusJakartaSans.ttf" "$app_path/"
cp "$source_root/Resources/BrandFonts/OFL-PlusJakartaSans.txt" "$app_path/"
cat > "$app_path/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>CircleUMotionSimulator</string>
<key>CFBundleIdentifier</key><string>com.circleu.prototype.motionsimulator</string>
<key>CFBundleName</key><string>CircleU Motion Simulator</string>
<key>CFBundleDisplayName</key><string>CircleU Motion Demo</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>MinimumOSVersion</key><string>17.0</string>
<key>UIDeviceFamily</key><array><integer>1</integer></array>
<key>UILaunchScreen</key><dict/>
<key>UISupportedInterfaceOrientations</key><array>
<string>UIInterfaceOrientationPortrait</string>
<string>UIInterfaceOrientationLandscapeLeft</string>
<string>UIInterfaceOrientationLandscapeRight</string>
</array>
</dict></plist>
PLIST
codesign --force --sign - "$app_path"
printf '\nBuilt isolated Simulator app: %s\n' "$app_path"
