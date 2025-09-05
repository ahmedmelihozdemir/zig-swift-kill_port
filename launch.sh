#!/bin/bash

# Port Kill Monitor - Quick Launch Script
# Builds and runs the application in one command

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Port Kill Monitor - Quick Launch${NC}"
echo ""

# Get current directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build Zig backend
echo -e "${YELLOW}[1/3]${NC} Building Zig backend..."
cd "$PROJECT_DIR/zig-backend"
zig build

# Build Swift frontend
echo -e "${YELLOW}[2/3]${NC} Building Swift frontend..."
cd "$PROJECT_DIR/swift-frontend"
xcodebuild -project swift-kill_port.xcodeproj 
           -scheme swift-frontend 
           -configuration Debug 
           build

# Launch the app
echo -e "${YELLOW}[3/3]${NC} Launching application..."
# Find and open the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "swift-kill_port.app" -type d | head -1)

if [ -n "$APP_PATH" ] && [ -d "$APP_PATH" ]; then
    open "$APP_PATH"
    echo -e "${GREEN}✅ Application launched successfully!${NC}"
    echo ""
    echo -e "${BLUE}Look for the ⚡ icon in your menu bar${NC}"
else
    echo "❌ Could not find built application"
    exit 1
fi
