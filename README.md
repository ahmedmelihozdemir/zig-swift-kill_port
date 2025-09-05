# Port Kill Monitor ⚡

A beautiful, minimalist macOS menu bar application for monitoring and managing processes on development ports. Built with Swift frontend and Zig backend for optimal performance.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue) ![Swift](https://img.shields.io/badge/Swift-5.5+-orange) ![Zig](https://img.shields.io/badge/Zig-0.15+-green) ![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- 🎨 **Beautiful Interface**: Clean, modern menu bar design
- ⚡ **Real-time Monitoring**: Automatically scans development ports (3000, 8080, etc.)
- 🎯 **One-Click Kill**: Terminate processes instantly
- 🔍 **Smart Search**: Filter processes by port or name
- 📱 **Menu Bar App**: Quick access from your menu bar
- � **CLI Tools**: Command-line interface for automation

## 🚀 Quick Installation

### Option 1: One-Click Setup (Recommended)

```bash
# Download and run the setup script
curl -fsSL https://raw.githubusercontent.com/ahmedmelihozdemir/zig-swift-kill_port/main/setup.sh | bash
```

### Option 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port

# Run the setup script
chmod +x setup.sh
./setup.sh
```

### Option 3: Development Mode

```bash
# Quick build and run for development
chmod +x launch.sh
./launch.sh
```

## 📱 Usage

### Menu Bar App
1. **Launch** Port Kill Monitor from Applications
2. **Look** for the ⚡ bolt icon in your menu bar  
3. **Click** to open the monitoring panel
4. **Search** for specific processes using the search bar
5. **Kill** unwanted processes with one click

### CLI Tools
After installation, use these commands in Terminal:

```bash
# Show help
port-kill --help

# Scan for processes on monitored ports
port-kill --scan

# Kill process on specific port
port-kill --kill 3000

# Kill all monitored processes  
port-kill --kill-all

# Use console version with detailed output
port-kill-console
```

## 🔧 Monitored Ports

The application automatically monitors these common development ports:

- **3000-3010**: React, Next.js, Node.js development servers
- **4000**: Express.js, Phoenix servers
- **5000**: Flask, Python development servers  
- **8000**: Django, Python HTTP servers
- **8080**: Tomcat, Jenkins, Java applications
- **8888**: Jupyter Notebook servers
- **9000**: Various development tools

## 🛠️ Requirements

- **macOS 12.0+** (Monterey or later)
- **Xcode Command Line Tools**
- **Homebrew** (for automatic Zig installation)

The setup script will automatically install missing dependencies.

## 🎨 Screenshots

### Menu Bar Interface
- Clean, modern design with smooth animations
- Real-time process monitoring  
- One-click process termination
- Smart search and filtering

### Settings Panel
- Customizable port monitoring
- Auto-refresh intervals
- Dark/light mode support

## 🏗️ Architecture

```
├── swift-frontend/          # macOS SwiftUI app (MVVM pattern)
│   ├── Views/              # User interface components
│   ├── ViewModels/         # Business logic
│   ├── Services/           # Backend communication
│   └── Models/             # Data structures
├── zig-backend/            # High-performance system monitoring
│   ├── src/               # Core Zig source code
│   ├── lib/               # Reusable modules
│   └── examples/          # Usage examples
└── scripts/               # Build and setup scripts
```
## 🔧 Development

### Quick Development Setup

```bash
# Clone and start developing immediately
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port

# Quick build and run
./launch.sh
```

### Manual Build Steps

```bash
# Build Zig backend
cd zig-backend
zig build

# Build Swift frontend  
cd ../swift-frontend
xcodebuild -project swift-kill_port.xcodeproj -scheme swift-frontend build

# Launch the app
open ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Debug/swift-kill_port.app
```

### Project Structure

- **Swift Frontend**: Modern SwiftUI interface with MVVM pattern
- **Zig Backend**: High-performance system monitoring and process management  
- **CLI Tools**: Command-line utilities for automation and scripting

## 🤝 Contributing

We welcome contributions! Here are some ways you can help:

- 🎨 **UI/UX**: Improve the beautiful SwiftUI interface
- ⚡ **Performance**: Optimize Zig backend efficiency  
- 📚 **Documentation**: Expand guides and examples
- 🐛 **Bug Fixes**: Help make the app more stable
- 🌍 **Localization**: Support for multiple languages

### Getting Started
1. Fork the repository
2. Create a feature branch
3. Make your changes and test thoroughly
4. Submit a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Swift/SwiftUI**: For the beautiful macOS interface
- **Zig Language**: For efficient system-level operations  
- **macOS Community**: For inspiration and feedback

## 💬 Support

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/ahmedmelihozdemir/zig-swift-kill_port/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/ahmedmelihozdemir/zig-swift-kill_port/discussions)
- 📧 **Contact**: [ozdemirmelihdev@gmail.com]
