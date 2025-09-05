# Port Kill Monitor 🚀

A beautiful, minimalist macOS menu bar application for monitoring and managing processes on development ports. Built with Swift frontend and Zig backend for optimal performance and user experience.

![Port Monitor Preview](https://img.shields.io/badge/macOS-Menu%20Bar%20App-blue) ![Swift](https://img.shields.io/badge/Swift-5.5+-orange) ![Zig](https://img.shields.io/badge/Zig-0.15+-green) ![License](https://img.shields.io/badge/License-MIT-green) ![Version](https://img.shields.io/badge/Version-1.0.0-blue)

## ✨ Features

- 🎨 **Beautiful Minimalist Design**: Clean, modern interface with smooth animations
- ⚡ **Real-time Monitoring**: Automatically scans common development ports
- 🎯 **One-Click Termination**: Kill individual processes or all at once
- 📱 **Menu Bar Integration**: Quick access from your menu bar
- 🛡️ **Safe Operation**: Confirmation dialogs and graceful process termination
- 🔧 **CLI Support**: Command-line tools for scripting and automation

## 🚀 Quick Start

### Easy Installation

1. **Run the installer** (recommended):
   ```bash
   curl -fsSL https://raw.githubusercontent.com/ahmedmelihozdemir/zig-swift-kill_port/main/install.sh | bash
   ```

2. **Or download manually**:
   - Download from [Releases](https://github.com/ahmedmelihozdemir/zig-swift-kill_port/releases)
   - Extract and move to Applications folder
   - Right-click and "Open" to bypass Gatekeeper

### Build from Source

```bash
# Clone repository
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port

# Run installer script
./install.sh
```

## 📱 Usage

1. **Launch** Port Monitor from Applications
2. **Look** for the ⚡ bolt icon in your menu bar
3. **Click** to open the monitoring panel
4. **Monitor** active processes on development ports
5. **Kill** unwanted processes with one click

### Monitored Ports
- **3000-3010**: React, Next.js, Node.js
- **4000**: Express.js, Phoenix
- **5000**: Flask, development servers
- **8000**: Django, Python HTTP server
- **8080**: Tomcat, Jenkins
- **8888**: Jupyter Notebook
- **9000**: Various development tools

## 🎨 Interface Highlights

- **Modern Design**: Beautiful gradients and smooth animations
- **Process Cards**: Clean display of port, PID, and process information
- **Smart Status**: Visual indicators for system state
- **Organized Menu**: Settings, help, and quick actions
- **Responsive UI**: Adapts to different content sizes

## 🔧 CLI Tools

After installation, you can also use command-line tools:

```bash
# Scan for processes on monitored ports
port-kill --scan

# Kill process on specific port
port-kill --kill 3000

# Kill all monitored processes
port-kill --kill-all

# Console version with detailed output
port-kill-console
```

##  Development

### Quick Setup

```bash
# Clone repository
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port

# Run installer script
./install.sh
```

### Architecture Overview

```
├── swift-frontend/          # macOS SwiftUI application (MVVM pattern)
│   ├── Views/              # SwiftUI user interface components
│   ├── ViewModels/         # Business logic and state management
│   ├── Services/           # Backend communication layer
│   ├── Models/             # Data models and structures
│   └── Managers/           # System integration managers
├── zig-backend/            # High-performance system monitoring
│   ├── src/               # Core Zig source code
│   ├── lib/               # Reusable library modules
│   └── examples/          # Usage examples and tests
└── docs/                  # Comprehensive documentation
```

## 🤝 Contributing

We welcome contributions! This project offers opportunities for both Swift frontend development and Zig backend optimization.

### Ways to Contribute

- 🎨 **UI/UX Improvements**: Enhance the beautiful SwiftUI interface
- ⚡ **Performance Optimization**: Improve Zig backend efficiency
- 📚 **Documentation**: Expand guides and examples
- 🐛 **Bug Fixes**: Help make the app more stable
- 🌍 **Localization**: Support for multiple languages
- 🔧 **New Features**: Additional monitoring capabilities

### Getting Started
1. **Fork the repository** and clone locally
2. **Check issues** for good first issues on GitHub
3. **Make your changes** and test thoroughly
4. **Submit a Pull Request** with clear description

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Swift/SwiftUI**: For the beautiful macOS interface
- **Zig Language**: For efficient system-level operations
- **macOS Community**: For inspiration and feedback

---

**Made with ❤️ by Ahmed Melih Özdemir**

If you find this project useful, please ⭐ star it on GitHub!
