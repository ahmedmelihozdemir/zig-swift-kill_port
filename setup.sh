#!/bin/bash

# Port Kill Monitor - One-Click Setup Script
# This script automatically builds and installs the Port Monitor application

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="swift-kill_port"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
FINAL_APP_PATH="/Applications/Port Kill Monitor.app"

# Pretty header
echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                Port Kill Monitor Setup                      ║"
echo "║                                                              ║"
echo "║  🚀 One-click installation for macOS menu bar app           ║"
echo "║  ⚡ Monitor and kill processes on development ports         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to print status messages
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[→]${NC} $1"
}

# Function to check macOS version
check_macos() {
    print_step "Checking macOS compatibility..."
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This application is only compatible with macOS"
        exit 1
    fi
    
    macos_version=$(sw_vers -productVersion)
    print_status "Running on macOS $macos_version"
}

# Function to check dependencies
check_dependencies() {
    print_step "Checking required dependencies..."
    
    local missing_deps=()
    
    # Check for Xcode/Command Line Tools
    if ! xcode-select -p &> /dev/null; then
        missing_deps+=("Xcode Command Line Tools")
    fi
    
    # Check for Zig
    if ! command -v zig &> /dev/null; then
        print_warning "Zig not found. Installing via Homebrew..."
        if command -v brew &> /dev/null; then
            brew install zig
            print_status "Zig installed successfully"
        else
            print_error "Homebrew not found. Please install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
    else
        zig_version=$(zig version)
        print_status "Zig $zig_version found"
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        if [[ " ${missing_deps[*]} " =~ " Xcode Command Line Tools " ]]; then
            print_info "Installing Xcode Command Line Tools..."
            xcode-select --install
            print_warning "Please run this script again after Xcode Command Line Tools installation completes"
            exit 1
        fi
    fi
    
    print_status "All dependencies satisfied"
}

# Function to build Zig backend
build_zig_backend() {
    print_step "Building Zig backend..."
    
    cd "$PROJECT_DIR/zig-backend"
    
    # Clean previous builds
    if [ -d "zig-out" ]; then
        rm -rf zig-out
    fi
    
    # Build the backend
    zig build
    
    if [ ! -f "zig-out/bin/kill-port" ]; then
        print_error "Failed to build Zig backend"
        exit 1
    fi
    
    print_status "Zig backend built successfully"
}

# Function to build Swift frontend
build_swift_frontend() {
    print_step "Building Swift frontend..."
    
    cd "$PROJECT_DIR/swift-frontend"
    
    # Clean previous builds
    if [ -d "build" ]; then
        rm -rf build
    fi
    
    # Build the Swift app
    xcodebuild -project swift-kill_port.xcodeproj \
               -scheme swift-frontend \
               -configuration Release \
               -derivedDataPath build \
               build
    
    # Find the built app
    local built_app_path=$(find build -name "*.app" -type d | head -1)
    
    if [ -z "$built_app_path" ] || [ ! -d "$built_app_path" ]; then
        print_error "Failed to build Swift frontend"
        exit 1
    fi
    
    # Create build directory and copy app
    mkdir -p "$BUILD_DIR"
    cp -R "$built_app_path" "$BUILD_DIR/$APP_NAME.app"
    
    print_status "Swift frontend built successfully"
}

# Function to copy Zig backend to app bundle
integrate_backend() {
    print_step "Integrating Zig backend with Swift frontend..."
    
    local app_path="$BUILD_DIR/$APP_NAME.app"
    local resources_path="$app_path/Contents/Resources"
    
    # Create Resources directory if it doesn't exist
    mkdir -p "$resources_path"
    
    # Copy Zig backend binaries
    cp "$PROJECT_DIR/zig-backend/zig-out/bin/kill-port" "$resources_path/"
    cp "$PROJECT_DIR/zig-backend/zig-out/bin/kill-port-console" "$resources_path/"
    
    # Make binaries executable
    chmod +x "$resources_path/kill-port"
    chmod +x "$resources_path/kill-port-console"
    
    print_status "Backend integration complete"
}

# Function to install the application
install_application() {
    print_step "Installing Port Kill Monitor..."
    
    local source_app="$BUILD_DIR/$APP_NAME.app"
    local final_name="Port Kill Monitor.app"
    local final_path="/Applications/$final_name"
    
    # Remove existing installation
    if [ -d "$final_path" ]; then
        print_warning "Removing existing installation..."
        rm -rf "$final_path"
    fi
    
    # Also remove old name if exists
    if [ -d "/Applications/$APP_NAME.app" ]; then
        rm -rf "/Applications/$APP_NAME.app"
    fi
    
    # Copy to Applications with better name
    cp -R "$source_app" "$final_path"
    
    # Fix permissions
    chmod -R 755 "$final_path"
    
    # Update final app path for other functions
    FINAL_APP_PATH="$final_path"
    
    print_status "Application installed to $final_path"
}

# Function to create CLI symlinks
setup_cli_tools() {
    print_step "Setting up CLI tools..."
    
    local bin_dir="/usr/local/bin"
    local resources_path="$FINAL_APP_PATH/Contents/Resources"
    
    # Create symlinks for CLI tools
    if [ -d "$bin_dir" ]; then
        # Remove existing symlinks
        [ -L "$bin_dir/port-kill" ] && rm "$bin_dir/port-kill"
        [ -L "$bin_dir/port-kill-console" ] && rm "$bin_dir/port-kill-console"
        
        # Create new symlinks
        ln -s "$resources_path/kill-port" "$bin_dir/port-kill" 2>/dev/null || true
        ln -s "$resources_path/kill-port-console" "$bin_dir/port-kill-console" 2>/dev/null || true
        
        if [ -L "$bin_dir/port-kill" ]; then
            print_status "CLI tools installed: port-kill, port-kill-console"
        else
            print_warning "CLI tools require manual setup (permission denied)"
            print_info "To install CLI tools manually, run:"
            echo "  sudo ln -s '$resources_path/kill-port' /usr/local/bin/port-kill"
            echo "  sudo ln -s '$resources_path/kill-port-console' /usr/local/bin/port-kill-console"
        fi
    fi
}

# Function to launch the application
launch_application() {
    print_step "Launching Port Kill Monitor..."
    
    # Open the application
    open "$FINAL_APP_PATH"
    
    print_status "Application launched successfully!"
}

# Function to show completion message
show_completion() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗"
    echo -e "║                  🎉 Installation Complete! 🎉                ║"
    echo -e "╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📱 Application Features:${NC}"
    echo "   • Real-time port monitoring"
    echo "   • One-click process termination"
    echo "   • Beautiful menu bar interface"
    echo "   • CLI tools for automation"
    echo ""
    echo -e "${BLUE}🚀 How to use:${NC}"
    echo "   1. Open Applications folder and launch 'Port Kill Monitor'"
    echo "   2. Look for the ⚡ icon in your menu bar (not dock!)"
    echo "   3. Click the ⚡ icon to open the monitoring panel"
    echo "   4. View and manage running processes"
    echo ""
    echo -e "${BLUE}💡 Quick Tips:${NC}"
    echo "   • Use ⌘+Space and type 'Port Kill Monitor' for quick launch"
    echo "   • Add to Login Items for auto-start"
    echo "   • The app runs in menu bar - no dock icon"
    echo ""
    echo -e "${BLUE}💻 CLI commands:${NC}"
    echo "   • port-kill --help          # Show help"
    echo "   • port-kill --scan          # Scan ports"
    echo "   • port-kill --kill 3000     # Kill process on port 3000"
    echo ""
    echo -e "${YELLOW}⭐ If you find this useful, please star the repository!${NC}"
    echo -e "${BLUE}   https://github.com/ahmedmelihozdemir/zig-swift-kill_port${NC}"
    echo ""
}

# Main installation flow
main() {
    echo "Starting automated installation..."
    echo ""
    
    check_macos
    check_dependencies
    build_zig_backend
    build_swift_frontend
    integrate_backend
    install_application
    setup_cli_tools
    launch_application
    
    show_completion
}

# Handle cleanup on exit
cleanup() {
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
    fi
}

trap cleanup EXIT

# Run main installation
main "$@"
