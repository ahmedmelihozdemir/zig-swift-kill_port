# Port Kill Monitor

A macOS menu bar application for monitoring and managing processes on development ports. Built with Swift frontend and Zig backend.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue) ![Swift](https://img.shields.io/badge/Swift-5.5+-orange) ![Zig](https://img.shields.io/badge/Zig-0.15+-green) ![License](https://img.shields.io/badge/License-MIT-green)

## Features

- Real-time monitoring of development ports (3000, 8080, etc.)
- One-click process termination
- Search and filter processes
- Menu bar integration
- Command-line interface

## Installation

### Quick Setup

```bash
curl -fsSL https://raw.githubusercontent.com/ahmedmelihozdemir/zig-swift-kill_port/main/setup.sh | bash
```

### Manual Installation

```bash
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port
chmod +x setup.sh
./setup.sh
```

## Usage

### Menu Bar App

1. Install using the setup script
2. Launch "Port Kill Monitor" from Applications
3. Click the bolt icon in your menu bar
4. Search and kill processes as needed

### CLI Commands

```bash
port-kill --help
port-kill --scan
port-kill --kill 3000
port-kill --kill-all
```

## Requirements

- macOS 12.0+
- Xcode Command Line Tools
- Homebrew

## Development

```bash
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port
./launch.sh
```

## License

MIT License - see [LICENSE](LICENSE) file for details.