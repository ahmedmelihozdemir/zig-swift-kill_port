#!/bin/bash

# Port Kill Zig - Easy Build and Run Script
# This script builds and runs the port-kill application
# Usage: ./run.sh [options]
# Examples:
#   ./run.sh                           # Default: ports 2000-6000 (GUI mode)
#   ./run.sh --start-port 3000         # Ports 3000-6000
#   ./run.sh --end-port 8080           # Ports 2000-8080  
#   ./run.sh --ports 3000,8000,8080    # Specific ports only
#   ./run.sh --console                 # Run in console mode
#   ./run.sh --verbose                 # Enable verbose logging

echo "🚀 Building and starting Zig Port Kill..."

# Check if zig is available
if ! command -v zig &> /dev/null; then
    echo "❌ Zig compiler not found. Please install Zig 0.15.0 or later."
    echo "   Download from: https://ziglang.org/download/"
    exit 1
fi

# Check Zig version (basic check)
ZIG_VERSION=$(zig version)
echo "📋 Using Zig version: $ZIG_VERSION"

# Build the application
echo "🔨 Building application..."
if ! zig build; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build completed successfully!"
echo "📊 Status bar icon should appear shortly (GUI mode)"
echo ""

# Check if console mode is requested
if [[ "$*" == *"--console"* || "$*" == *"-c"* ]]; then
    echo "💻 Running in console mode..."
    ./zig-out/bin/port-kill-console "$@"
else
    echo "🖥️  Running in GUI mode..."
    echo "   Look for a number in your macOS status bar!"
    ./zig-out/bin/port-kill "$@"
fi
