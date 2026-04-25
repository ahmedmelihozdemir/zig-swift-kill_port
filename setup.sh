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

# Function to print status messages (defined early for use throughout script)
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

print_command() {
    echo -e "${BLUE}    \$ $1${NC}"
}

# Configuration
APP_NAME="swift-kill_port"
REPO_URL="https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git"
TEMP_DIR="/tmp/port-kill-install-$$"
PREBUILT_ASSET_URL="https://github.com/ahmedmelihozdemir/zig-swift-kill_port/releases/latest/download/PortKillMonitor-macOS.tar.gz"

# Pretty header (show immediately)
echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                Port Kill Monitor Setup                       ║"
echo "║                                                              ║"
echo "║  One-click installation for macOS menu bar app               ║"
echo "║  Monitor and kill processes on development ports             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Determine project directory
# First, try to find a local project directory
SCRIPT_PATH="${BASH_SOURCE[0]}"
PROJECT_DIR=""

# Try to get directory from script path
if [[ -n "$SCRIPT_PATH" ]] && [[ "$SCRIPT_PATH" != "/dev/fd/"* ]] && [[ "$SCRIPT_PATH" != *"/proc/self/fd/"* ]]; then
    POTENTIAL_DIR="$(cd "$(dirname "$SCRIPT_PATH")" 2>/dev/null && pwd)"
    if [[ -d "$POTENTIAL_DIR/zig-backend" ]] && [[ -d "$POTENTIAL_DIR/swift-frontend" ]]; then
        PROJECT_DIR="$POTENTIAL_DIR"
    fi
fi

# If no valid local project found, we need to clone
if [[ -z "$PROJECT_DIR" ]] || [[ ! -d "$PROJECT_DIR/zig-backend" ]]; then
    print_step "Downloading source code..."
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    
    # Clone the repository
    if command -v git &> /dev/null; then
        git clone "$REPO_URL" "$TEMP_DIR" --depth 1 || {
            print_error "Failed to clone repository"
            exit 1
        }
    else
        print_error "Git is required but not installed"
        exit 1
    fi
    
    PROJECT_DIR="$TEMP_DIR"
    print_status "Source code downloaded to $PROJECT_DIR"
fi

# Verify project structure
if [[ ! -d "$PROJECT_DIR/zig-backend" ]]; then
    print_error "Project structure invalid: zig-backend not found in $PROJECT_DIR"
    exit 1
fi

BUILD_DIR="$PROJECT_DIR/build"
FINAL_APP_PATH="/Applications/Port Kill Monitor.app"
SKIP_PREBUILT=false

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
    
    # Check for Git
    if ! command -v git &> /dev/null; then
        missing_deps+=("Git")
    fi

    # Check for curl
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
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
        print_info "Please install the missing dependencies and run setup again."
        exit 1
    fi
    
    print_status "All dependencies satisfied"
}

# Function to check whether full Xcode is available for frontend build
require_full_xcode() {
    print_step "Checking Xcode availability for Swift build..."

    if ! xcode-select -p &> /dev/null; then
        print_error "Xcode developer tools are not configured"
        print_info "Run the command below, complete the installer, then rerun setup:"
        print_command "xcode-select --install"
        exit 1
    fi

    local dev_dir
    dev_dir="$(xcode-select -p)"

    if ! command -v xcodebuild &> /dev/null; then
        print_error "xcodebuild not found. Full Xcode is required to build the app frontend."
        print_info "Install Xcode from the App Store, open it once, then run:"
        print_command "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer"
        exit 1
    fi

    if ! xcodebuild -version &> /dev/null; then
        print_error "xcodebuild is installed but cannot build from '$dev_dir'"

        if [[ "$dev_dir" == "/Library/Developer/CommandLineTools" ]]; then
            print_info "You're currently using Command Line Tools only."
            print_info "This project needs full Xcode for the macOS app build."
            print_info "Install/open Xcode, then switch developer directory:"
            print_command "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer"
        else
            print_info "Open Xcode once and accept the license, then rerun setup."
            print_command "sudo xcodebuild -license accept"
        fi

        exit 1
    fi

    print_status "Xcode is ready for Swift frontend build"
}

# Function to install latest prebuilt app from GitHub releases
install_prebuilt_if_available() {
    if [ "$SKIP_PREBUILT" = true ]; then
        print_info "Skipping prebuilt installation (requested by user)"
        return 1
    fi

    print_step "Checking for prebuilt app release..."

    local prebuilt_dir="$PROJECT_DIR/prebuilt-install"
    local prebuilt_tar="$prebuilt_dir/PortKillMonitor-macOS.tar.gz"

    mkdir -p "$prebuilt_dir"

    if ! curl -fsSL "$PREBUILT_ASSET_URL" -o "$prebuilt_tar"; then
        print_warning "No prebuilt release found. Falling back to source build."
        return 1
    fi

    tar -xzf "$prebuilt_tar" -C "$prebuilt_dir" || {
        print_warning "Prebuilt archive could not be extracted. Falling back to source build."
        return 1
    }

    local prebuilt_app=""
    for app_candidate in "$prebuilt_dir"/*.app; do
        if [ -d "$app_candidate" ]; then
            prebuilt_app="$app_candidate"
            break
        fi
    done

    if [ -z "$prebuilt_app" ]; then
        print_warning "No .app found inside release archive. Falling back to source build."
        return 1
    fi

    mkdir -p "$BUILD_DIR"
    cp -R "$prebuilt_app" "$BUILD_DIR/$APP_NAME.app"
    print_status "Prebuilt app downloaded successfully"
    return 0
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
    require_full_xcode
    
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

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --build-from-source)
                SKIP_PREBUILT=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--build-from-source]"
                echo ""
                echo "Options:"
                echo "  --build-from-source   Skip prebuilt release and build locally"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    check_macos
    check_dependencies

    if ! install_prebuilt_if_available; then
        build_zig_backend
        build_swift_frontend
        integrate_backend
    fi

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

    if [ -d "$PROJECT_DIR/prebuilt-install" ]; then
        rm -rf "$PROJECT_DIR/prebuilt-install"
    fi
    
    # Clean up temporary directory if it was created for remote execution
    if [[ -n "$TEMP_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

# Run main installation
main "$@"
