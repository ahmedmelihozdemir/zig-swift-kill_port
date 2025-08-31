#!/bin/bash

# Port Monitor - Installation Setup Script
# This script helps users set up the Port Monitor application

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="Port Monitor"
REPO_URL="https://github.com/ahmedmelihozdemir/zig-swift-kill_port"
REQUIRED_MACOS_VERSION="11.0"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Port Monitor Setup                        ║"
echo "║                                                              ║"
echo "║  A beautiful macOS menu bar app for monitoring and          ║"
echo "║  managing processes on development ports                     ║"
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

# Function to check macOS version
check_macos_version() {
    print_info "Checking macOS version..."
    
    macos_version=$(sw_vers -productVersion)
    macos_major=$(echo $macos_version | cut -d. -f1)
    macos_minor=$(echo $macos_version | cut -d. -f2)
    
    required_major=$(echo $REQUIRED_MACOS_VERSION | cut -d. -f1)
    required_minor=$(echo $REQUIRED_MACOS_VERSION | cut -d. -f2)
    
    if [[ $macos_major -gt $required_major ]] || [[ $macos_major -eq $required_major && $macos_minor -ge $required_minor ]]; then
        print_status "macOS version $macos_version is compatible"
        return 0
    else
        print_error "macOS $REQUIRED_MACOS_VERSION or later is required. Found: $macos_version"
        return 1
    fi
}

# Function to check for required tools
check_dependencies() {
    print_info "Checking dependencies..."
    
    local missing_deps=()
    
    # Check for Xcode or Command Line Tools
    if ! xcode-select -p &> /dev/null; then
        missing_deps+=("Xcode Command Line Tools")
    fi
    
    # Check for Git
    if ! command -v git &> /dev/null; then
        missing_deps+=("Git")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_info "Please install the missing dependencies and run this script again."
        
        if [[ " ${missing_deps[*]} " =~ " Xcode Command Line Tools " ]]; then
            print_info "To install Xcode Command Line Tools, run: xcode-select --install"
        fi
        
        return 1
    fi
    
    print_status "All dependencies are satisfied"
    return 0
}

# Function to create application directory
setup_directories() {
    print_info "Setting up directories..."
    
    local app_dir="$HOME/Applications"
    
    if [ ! -d "$app_dir" ]; then
        mkdir -p "$app_dir"
        print_status "Created $app_dir directory"
    fi
    
    print_status "Directory setup complete"
}

# Function to clone or update repository
setup_repository() {
    print_info "Setting up repository..."
    
    local repo_dir="$HOME/Developer/port-monitor"
    
    if [ -d "$repo_dir" ]; then
        print_warning "Repository already exists. Updating..."
        cd "$repo_dir"
        git pull origin main
    else
        print_info "Cloning repository..."
        mkdir -p "$HOME/Developer"
        cd "$HOME/Developer"
        git clone "$REPO_URL" port-monitor
        cd port-monitor
    fi
    
    print_status "Repository setup complete"
    echo "Repository location: $repo_dir"
}

# Function to build the application
build_application() {
    print_info "Building Port Monitor application..."
    
    local repo_dir="$HOME/Developer/port-monitor"
    cd "$repo_dir"
    
    # Build Zig backend
    print_info "Building Zig backend..."
    cd zig-backend
    
    if ! command -v zig &> /dev/null; then
        print_warning "Zig not found. Attempting to install via Homebrew..."
        if command -v brew &> /dev/null; then
            brew install zig
        else
            print_error "Homebrew not found. Please install Zig manually from https://ziglang.org/"
            return 1
        fi
    fi
    
    zig build -Doptimize=ReleaseFast
    print_status "Zig backend built successfully"
    
    # Build Swift frontend
    print_info "Building Swift frontend..."
    cd ../swift-frontend
    
    xcodebuild -scheme swift-frontend -configuration Release -derivedDataPath build clean build
    print_status "Swift frontend built successfully"
    
    print_status "Application build complete"
}

# Function to install the application
install_application() {
    print_info "Installing Port Monitor..."
    
    local repo_dir="$HOME/Developer/port-monitor"
    local app_dir="$HOME/Applications"
    local build_dir="$repo_dir/swift-frontend/build/Build/Products/Release"
    
    if [ -d "$build_dir/swift-frontend.app" ]; then
        cp -R "$build_dir/swift-frontend.app" "$app_dir/Port Monitor.app"
        print_status "Port Monitor installed to $app_dir"
    else
        print_error "Build output not found. Please check the build process."
        return 1
    fi
}

# Function to setup CLI tools
setup_cli() {
    print_info "Setting up CLI tools..."
    
    local repo_dir="$HOME/Developer/port-monitor"
    local cli_dir="/usr/local/bin"
    
    # Create symlink for CLI tool
    if [ -f "$repo_dir/zig-backend/zig-out/bin/port-kill" ]; then
        sudo ln -sf "$repo_dir/zig-backend/zig-out/bin/port-kill" "$cli_dir/port-kill"
        sudo ln -sf "$repo_dir/zig-backend/zig-out/bin/port-kill-console" "$cli_dir/port-kill-console"
        print_status "CLI tools installed to $cli_dir"
    else
        print_warning "CLI tools not found. Skipping CLI setup."
    fi
}

# Function to create uninstaller
create_uninstaller() {
    print_info "Creating uninstaller..."
    
    local uninstall_script="$HOME/Applications/Uninstall Port Monitor.command"
    
    cat > "$uninstall_script" << 'EOF'
#!/bin/bash

echo "Uninstalling Port Monitor..."

# Remove application
rm -rf "$HOME/Applications/Port Monitor.app"

# Remove CLI tools
sudo rm -f /usr/local/bin/port-kill
sudo rm -f /usr/local/bin/port-kill-console

# Remove repository (optional)
read -p "Remove source code repository? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/Developer/port-monitor"
fi

echo "Port Monitor has been uninstalled."
echo "This uninstaller will self-destruct in 3 seconds..."
sleep 3
rm "$0"
EOF
    
    chmod +x "$uninstall_script"
    print_status "Uninstaller created"
}

# Function to show completion message
show_completion() {
    echo
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 🎉 Installation Complete! 🎉                 ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    print_status "Port Monitor has been successfully installed!"
    echo
    print_info "Next steps:"
    echo "  1. Open Port Monitor from Applications or Launchpad"
    echo "  2. Look for the ⚡ bolt icon in your menu bar"
    echo "  3. Click the icon to start monitoring ports"
    echo
    print_info "CLI Usage:"
    echo "  • port-kill --scan           # Scan for processes"
    echo "  • port-kill --kill 3000      # Kill process on port 3000"
    echo "  • port-kill --kill-all       # Kill all monitored processes"
    echo
    print_info "Documentation:"
    echo "  • User Guide: $HOME/Developer/port-monitor/USER_GUIDE.md"
    echo "  • Repository: $REPO_URL"
    echo
    print_warning "Security Note:"
    echo "  When first opening the app, right-click and select 'Open'"
    echo "  to bypass macOS Gatekeeper security."
}

# Main installation flow
main() {
    # Parse command line arguments
    SKIP_BUILD=false
    VERBOSE=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                set -x
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --skip-build    Skip building and use existing binaries"
                echo "  --verbose       Enable verbose output"
                echo "  --help          Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Run installation steps
    if ! check_macos_version; then
        exit 1
    fi
    
    if ! check_dependencies; then
        exit 1
    fi
    
    setup_directories
    setup_repository
    
    if [ "$SKIP_BUILD" = false ]; then
        if ! build_application; then
            print_error "Build failed. Installation aborted."
            exit 1
        fi
    fi
    
    if ! install_application; then
        print_error "Installation failed."
        exit 1
    fi
    
    setup_cli
    create_uninstaller
    show_completion
}

# Run main function
main "$@"
