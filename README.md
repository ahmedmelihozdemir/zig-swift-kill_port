# Port Kill Monitor

A lightweight macOS menu bar application for monitoring and managing processes running on development ports. The application combines a Swift-based user interface with a high-performance Zig backend for efficient process management.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue) ![Swift](https://img.shields.io/badge/Swift-5.5+-orange) ![Zig](https://img.shields.io/badge/Zig-0.15+-green) ![License](https://img.shields.io/badge/License-MIT-green)

## Overview

Port Kill Monitor helps developers quickly identify and terminate processes occupying commonly used development ports. Instead of manually running terminal commands to find and kill processes, you can manage everything through a clean menu bar interface or convenient CLI tools.

## Features

- **Real-time Port Monitoring** - Automatically scans and displays processes running on common development ports (3000, 8080, 5000, etc.)
- **One-Click Process Termination** - Kill any process directly from the menu bar with a single click
- **Search and Filter** - Quickly find specific processes or ports
- **Menu Bar Integration** - Lightweight app that lives in your menu bar, always accessible but never intrusive
- **Command-Line Interface** - Full CLI support for automation and scripting
- **Native Performance** - Swift frontend with Zig backend for optimal speed and resource usage

## Installation

### Quick Installation (Recommended)

Run this single command to download and install everything automatically:

```bash
curl -fsSL https://raw.githubusercontent.com/ahmedmelihozdemir/zig-swift-kill_port/main/setup.sh | bash
```

The installation script will:

- Check your macOS version compatibility
- Try to download a prebuilt app from latest GitHub Release
- Fall back to local source build if no prebuilt release exists
- Verify full Xcode availability only when local Swift build is needed
- Install Zig via Homebrew if needed for local build
- Install the app to your Applications folder
- Set up CLI tools
- Launch the application

You can force local compilation at any time:

```bash
curl -fsSL https://raw.githubusercontent.com/ahmedmelihozdemir/zig-swift-kill_port/main/setup.sh | bash -s -- --build-from-source
```

### Important Build Requirement

`xcodebuild` must come from **full Xcode**, not only Command Line Tools.

If you see this error during setup:

`tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance`

fix it with:

```bash
# 1) Install and open Xcode once from App Store
# 2) Switch active developer directory
sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
```

### Manual Installation

If you prefer to review the code first or want more control:

```bash
# Clone the repository
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port

# Make the setup script executable
chmod +x setup.sh

# Run the installation
./setup.sh
```

## Usage

### Menu Bar Application

After installation, you'll find "Port Kill Monitor" in your Applications folder:

1. Launch the app from Applications or use Spotlight (⌘+Space, then type "Port Kill Monitor")
2. Look for the lightning bolt icon in your menu bar (top-right area of your screen)
3. Click the icon to open the monitoring panel
4. View all processes currently running on monitored ports
5. Click any process to terminate it instantly

**Note:** This is a menu bar application, so it won't appear in your Dock. Look for the icon in your menu bar instead.

### Command-Line Interface

The installation also provides CLI tools for terminal usage:

```bash
# Display help and available options
port-kill --help

# Scan and display all processes on monitored ports
port-kill --scan

# Kill a specific process by port number
port-kill --kill 3000

# Terminate all processes on monitored ports
port-kill --kill-all
```

These commands are useful for automation scripts or when you prefer working in the terminal.

## System Requirements

- **Operating System:** macOS 12.0 (Monterey) or later
- **Development Tools:** Full Xcode (required for Swift app build)
- **Package Manager:** Homebrew (for Zig installation)

If you don't have these installed, the setup script will guide you through installing them.

## Development

To run the application in development mode without installing:

```bash
# Clone the repository
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port

# Launch in development mode
./launch.sh
```

The `launch.sh` script builds both components and runs the app directly without installing to Applications.

### Project Structure

```
port_kill/
├── swift-frontend/     # Swift-based UI and menu bar integration
├── zig-backend/        # High-performance Zig backend for process management
├── setup.sh           # Automated installation script
├── launch.sh          # Development mode launcher
└── README.md          # This file
```

## Troubleshooting

**xcodebuild requires full Xcode:**

```bash
sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
xcodebuild -version
```

**Xcode Command Line Tools missing:**

```bash
xcode-select --install
```

**Homebrew not found:**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**App won't launch after installation:**

- Right-click the app and select "Open" to bypass Gatekeeper on first launch
- Check System Settings → Privacy & Security for any blocks

**CLI commands not found:**
If `port-kill` commands aren't working, you may need to manually create symlinks:

```bash
sudo ln -s "/Applications/Port Kill Monitor.app/Contents/Resources/kill-port" /usr/local/bin/port-kill
```

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## Release Pipeline

Prebuilt installer assets are produced automatically by GitHub Actions on every tag that matches `v*` (for example `v1.0.0`).

```bash
git tag v1.0.0
git push origin v1.0.0
```

This uploads `PortKillMonitor-macOS.tar.gz` to the release page, and `setup.sh` automatically consumes that artifact for one-command installation.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

Built with Swift for the frontend and Zig for the backend, combining the best of both ecosystems for a fast, native macOS experience.
