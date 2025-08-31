#!/bin/bash

# Port Monitor Launcher Script
# Simple script to launch the Port Monitor application

APP_NAME="Port Monitor"
APP_PATH="/Applications/Port Monitor.app"
BUILD_PATH="$HOME/Library/Developer/Xcode/DerivedData/swift-frontend*/Build/Products/Debug/swift-frontend.app"

echo "🚀 Starting Port Monitor..."

# Check if app is installed in Applications
if [ -d "$APP_PATH" ]; then
    echo "📱 Found installed app at $APP_PATH"
    open "$APP_PATH"
    exit 0
fi

# Check for development build
if ls $BUILD_PATH 1> /dev/null 2>&1; then
    DEV_BUILD=$(ls $BUILD_PATH 2>/dev/null | head -1)
    if [ -d "$DEV_BUILD" ]; then
        echo "🔧 Found development build at $DEV_BUILD"
        open "$DEV_BUILD"
        exit 0
    fi
fi

# App not found
echo "❌ Port Monitor not found!"
echo ""
echo "To install Port Monitor:"
echo "1. Run the installer: ./install.sh"
echo "2. Or build from source: cd swift-frontend && xcodebuild -scheme swift-frontend build"
echo "3. Or download from releases: https://github.com/ahmedmelihozdemir/zig-swift-kill_port/releases"
exit 1
