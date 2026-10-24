#!/bin/bash
set -euo pipefail

prototype_root="$(cd "$(dirname "$0")/.." && pwd)"
build_root="${CIRCLEU_PREVIEW_BUILD_DIR:-/tmp/circleu-visual-preview-build}"
app_path="${CIRCLEU_MOTION_APP_PATH:-/tmp/CircleU Motion Demo.app}"
developer_path="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
swift_path="$developer_path/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift"
export DEVELOPER_DIR="$developer_path"
export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-/tmp/circleu-preview-clang-cache}"
export SWIFTPM_MODULECACHE_OVERRIDE="${SWIFTPM_MODULECACHE_OVERRIDE:-/tmp/circleu-preview-module-cache}"

cd "$prototype_root"
"$swift_path" build --scratch-path "$build_root" --product motion-demo
bin_path="$("$swift_path" build --scratch-path "$build_root" --show-bin-path)"
mkdir -p "$app_path/Contents/MacOS" "$app_path/Contents/Resources"
cp "$bin_path/motion-demo" "$app_path/Contents/MacOS/CircleUMotionDemo"
cp -R "$bin_path/CircleUVisualPrototype_CircleUVisualPrototype.bundle" "$app_path/Contents/Resources/"
cat > "$app_path/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>CircleUMotionDemo</string>
<key>CFBundleIdentifier</key><string>com.circleu.prototype.motiondemo</string>
<key>CFBundleName</key><string>CircleU Motion Demo</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>NSHighResolutionCapable</key><true/>
<key>NSPrincipalClass</key><string>NSApplication</string>
</dict></plist>
PLIST
codesign --force --sign - "$app_path"
printf '\nBuilt isolated review app: %s\n' "$app_path"
