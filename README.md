# Port Monitor 🚀

A beautiful, minimalist macOS menu bar application for monitoring and managing processes on development ports.

![Port Monitor Preview](https://img.shields.io/badge/macOS-Menu%20Bar%20App-blue) ![Swift](https://img.shields.io/badge/Swift-5.5+-orange) ![Zig](https://img.shields.io/badge/Zig-0.15+-green)

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

## 📖 Documentation

- **[User Guide](USER_GUIDE.md)**: Comprehensive usage instructions
- **[API Documentation](docs/API.md)**: For developers
- **[Contributing](CONTRIBUTING.md)**: How to contribute

## 🛠 Development

### Project Structure

```
├── swift-frontend/          # macOS SwiftUI application
│   ├── Views/              # UI components
│   ├── ViewModels/         # Business logic
│   ├── Services/           # Backend communication
│   └── Models/             # Data models
├── zig-backend/            # Zig backend for process monitoring
│   ├── src/               # Source code
│   ├── lib/               # Libraries
│   └── examples/          # Usage examples
└── docs/                  # Documentation
```

### Requirements

- **macOS**: 11.0+ (Big Sur or later)
- **Xcode**: 13.0+ (for Swift frontend)
- **Zig**: 0.15+ (for backend)

### Building

```bash
# Build backend
cd zig-backend
zig build -Doptimize=ReleaseFast

# Build frontend
cd ../swift-frontend
xcodebuild -scheme swift-frontend -configuration Release build
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md).

### Areas for Contribution

- 🎨 **UI/UX Improvements**: Make the interface even more beautiful
- 🔧 **New Features**: Additional monitoring capabilities
- 📚 **Documentation**: Improve guides and examples
- 🐛 **Bug Fixes**: Help make the app more stable
- 🌍 **Localization**: Support for multiple languages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Swift/SwiftUI**: For the beautiful macOS interface
- **Zig Language**: For efficient system-level operations
- **macOS Community**: For inspiration and feedback

---

**Made with ❤️ by Ahmed Melih Özdemir**

If you find this project useful, please ⭐ star it on GitHub!
