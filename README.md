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
- Install Zig via Homebrew if needed
- Build both the backend and frontend
- Install the app to your Applications folder
- Set up CLI tools
- Launch the application

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
- **Development Tools:** Xcode Command Line Tools
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

**"Permission denied" errors during installation:**

```bash
sudo xcode-select --install
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

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

Built with Swift for the frontend and Zig for the backend, combining the best of both ecosystems for a fast, native macOS experience.
