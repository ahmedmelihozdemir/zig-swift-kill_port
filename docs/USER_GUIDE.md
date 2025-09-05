# Port Monitor - User Guide

![Port Monitor](https://img.shields.io/badge/Version-1.0-blue) ![macOS](https://img.shields.io/badge/macOS-11.0+-green) ![Swift](https://img.shields.io/badge/Swift-5.5+-orange)

**Port Monitor** is a sleek, minimalist macOS menu bar application that helps you monitor and manage processes running on specific ports. With its beautiful interface and powerful backend, you can easily identify and terminate unwanted processes that might be blocking your development workflow.

## 🚀 Features

- **Real-time Port Monitoring**: Automatically scans and displays processes using common development ports
- **One-Click Process Termination**: Kill individual processes or all processes at once
- **Beautiful Minimalist Design**: Clean, modern interface with smooth animations
- **Menu Bar Integration**: Lives in your menu bar for quick access
- **Smart Status Updates**: Visual indicators for system status
- **Safe Operation**: Confirmation dialogs for critical operations

## 📋 System Requirements

- **macOS**: 11.0 (Big Sur) or later
- **Architecture**: Intel x64 or Apple Silicon (M1/M2/M3)
- **Permissions**: Terminal access for process monitoring

## 🛠 Installation

### Option 1: Download Pre-built Binary (Recommended)

1. **Download** the latest release from the [GitHub Releases](https://github.com/ahmedmelihozdemir/zig-swift-kill_port/releases) page
2. **Extract** the downloaded ZIP file
3. **Move** `Port Monitor.app` to your `/Applications` folder
4. **Right-click** the app and select "Open" to bypass Gatekeeper
5. **Grant permissions** when prompted for Terminal access

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port

# Build the Swift frontend
cd swift-frontend
xcodebuild -scheme swift-frontend -configuration Release build

# Build the Zig backend
cd ../zig-backend
zig build -Doptimize=ReleaseFast
```

## 🎯 How to Use

### Getting Started

1. **Launch** the app from Applications or Launchpad
2. **Look** for the bolt icon (⚡) in your menu bar
3. **Click** the icon to open the Port Monitor panel

### Main Interface

#### Header Section
- **Port Monitor Title**: Shows app name and description
- **Refresh Button** (🔄): Manually refresh the process list
- **Status Card**: Displays current system status and process count

#### Process List
- **Port Badge**: Shows the port number in a blue circular badge
- **Process Info**: Displays process name, PID, and command
- **Kill Button** (⊗): Terminate individual processes

#### Action Buttons
- **Kill All Processes**: Terminates all monitored processes at once
- **Menu**: Access settings, help, and app information
- **Auto**: Toggle automatic refresh (coming soon)
- **Quit**: Exit the application

### Monitored Ports

The application automatically monitors these commonly used development ports:

- **3000**: React, Next.js development servers
- **3001-3010**: Additional React/Node.js instances
- **4000**: Express.js, Phoenix
- **5000**: Flask, various development servers
- **8000**: Django, Python HTTP server
- **8080**: Tomcat, Jenkins, alternative HTTP
- **8888**: Jupyter Notebook
- **9000**: Various development tools

## ⚙️ Configuration

### Auto-Refresh Settings
- **Default**: Every 5 seconds
- **Range**: 1-60 seconds
- **Manual**: Disable auto-refresh and scan manually

### Notification Preferences
- **Process Killed**: Show success notifications
- **Errors**: Display error alerts
- **Status Changes**: System status updates

## 🔒 Security & Permissions

### Required Permissions

1. **Terminal Access**: Required to scan for processes
2. **System Events**: Optional, for enhanced integration

### Privacy Notes

- **No Data Collection**: The app doesn't collect or transmit any personal data
- **Local Operation**: All scanning and process management happens locally
- **No Network Access**: The app doesn't require internet connectivity

## 🛡️ Safety Features

- **Confirmation Dialogs**: Critical actions require confirmation
- **Process Validation**: Only shows processes actually using monitored ports
- **Safe Termination**: Uses SIGTERM before SIGKILL for graceful shutdown
- **Error Handling**: Comprehensive error messages and recovery

## 🎨 Interface Guide

### Visual Indicators

| Indicator | Meaning |
|-----------|---------|
| 🟢 Green checkmark | All ports are free |
| 🟠 Orange warning | Active processes detected |
| 🔵 Blue spinning | Scanning in progress |
| 🔴 Red gradient | Kill action available |

### Animations
- **Smooth Transitions**: All UI changes are smoothly animated
- **Rotation Effects**: Refresh button spins during scanning
- **Scale Feedback**: Buttons provide visual feedback when pressed

## 🔧 Troubleshooting

### Common Issues

**Problem**: App won't open or crashes on launch
**Solution**: 
1. Check macOS compatibility (11.0+)
2. Right-click and "Open" to bypass Gatekeeper
3. Restart your Mac and try again

**Problem**: No processes shown when they should be there
**Solution**:
1. Click the refresh button manually
2. Check if processes are actually using the monitored ports
3. Grant Terminal access permissions if prompted

**Problem**: Can't kill processes
**Solution**:
1. Ensure you have administrator privileges
2. Try killing processes individually instead of all at once
3. Some system processes may be protected

### Getting Help

- **GitHub Issues**: [Report bugs or request features](https://github.com/ahmedmelihozdemir/zig-swift-kill_port/issues)
- **Documentation**: This guide and in-app help
- **Community**: Discussions on GitHub

## 🚀 Advanced Usage

### Keyboard Shortcuts
- **⌘R**: Refresh process list
- **⌘Q**: Quit application
- **⌘,**: Open preferences (coming soon)

### Command Line Integration
The app includes a command-line version for scripting:

```bash
# Install CLI tool
./install-cli.sh

# Usage examples
port-kill --scan          # Scan for processes
port-kill --kill 3000     # Kill process on port 3000
port-kill --kill-all      # Kill all monitored processes
```

## 🔄 Updates

### Automatic Updates
- **Check for Updates**: Built-in update checker (coming soon)
- **Download**: Updates available through GitHub Releases
- **Notification**: Get notified when new versions are available

### Version History
Check the [CHANGELOG.md](CHANGELOG.md) file for detailed version history and changes.

## 👥 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- **Bug Reports**: How to report issues effectively
- **Feature Requests**: Suggesting new functionality
- **Code Contributions**: Pull request process
- **Documentation**: Improving this guide

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Zig Language**: For the efficient backend implementation
- **Swift/SwiftUI**: For the beautiful macOS interface
- **Community**: For feedback and contributions

---

**Made with ❤️ by Ahmed Melih Özdemir**

For more information, visit our [GitHub Repository](https://github.com/ahmedmelihozdemir/zig-swift-kill_port).
