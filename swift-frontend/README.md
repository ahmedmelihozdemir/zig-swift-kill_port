# Port Kill Monitor - Swift Frontend

A modern macOS menu bar application built with SwiftUI and MVVM architecture for monitoring and managing processes on development ports.

![Swift Frontend](https://img.shields.io/badge/Swift-5.5+-orange) ![SwiftUI](https://img.shields.io/badge/SwiftUI-MVVM-blue) ![macOS](https://img.shields.io/badge/macOS-11.0+-green)

## 🚀 Features

- **Menu Bar Integration**: Persistent system menu bar application with elegant bolt icon
- **Real-time Monitoring**: Automatic port scanning every 2 seconds with live updates
- **Modern SwiftUI Interface**: Beautiful, responsive user interface with smooth animations
- **MVVM Architecture**: Clean code principles with testable, maintainable structure
- **Safe Process Management**: Graceful SIGTERM/SIGKILL process termination
- **Sandbox Compatible**: Designed to work within macOS security requirements

## 🏗️ Architecture

### MVVM (Model-View-ViewModel) Pattern
```
Models/
├── ProcessInfo.swift          # Process data model
└── StatusBarInfo.swift        # Status bar information model

ViewModels/
└── MenuBarViewModel.swift     # Business logic and state management

Views/
├── MenuBarView.swift          # Main SwiftUI interface components
└── SettingsView.swift         # Configuration interface

Services/
└── PortKillService.swift      # Backend communication layer

Managers/
└── MenuBarManager.swift       # macOS menu bar integration
```

## 🔧 Technical Details

### Technologies Used
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data binding
- **Foundation Process**: System command execution
- **AppKit**: macOS menu bar integration
- **Async/Await**: Modern asynchronous programming

### Monitored Ports (Default)
- **3000, 3001**: Development servers (React, Next.js, Node.js)
- **4000**: Express.js, Phoenix Framework
- **5000**: Flask, development servers
- **8000**: Django, Python HTTP server
- **8080**: Tomcat, Jenkins, alternative HTTP
- **8888**: Jupyter Notebook
- **9000**: Various development tools

### Security Features
- **Sandbox support**: Disabled for system command requirements
- **Network permissions**: Client/server network access
- **File access permissions**: Required for process monitoring
- **User consent**: All process terminations require user interaction

## 🚦 Setup and Installation

### Requirements
- **macOS**: 11.0+ (Big Sur or later)
- **Xcode**: 14.0+
- **Swift**: 5.5+

### Build Instructions
```bash
cd swift-frontend

# Debug build
xcodebuild -project swift-frontend.xcodeproj \
           -scheme swift-frontend \
           -configuration Debug \
           build

# Release build
xcodebuild -project swift-frontend.xcodeproj \
           -scheme swift-frontend \
           -configuration Release \
           build
```

### Running the Application
```bash
# From Xcode
# Open swift-frontend.xcodeproj and press ⌘+R

# From command line (after build)
open /path/to/DerivedData/swift-frontend-*/Build/Products/Debug/swift-frontend.app
```

## 🎯 Usage

1. **Launch Application**: Look for the ⚡ bolt icon in your menu bar
2. **Open Monitor Panel**: Click the icon to open the monitoring popover
3. **View Process List**: See active processes with port and PID information
4. **Terminate Individual Process**: Click the ❌ button next to each process
5. **Terminate All Processes**: Use the "Kill All Processes" button
6. **Access Settings**: Click the menu button (⋯) for configuration options

## 📋 Interface Components

### MenuBarView
- **Header Section**: App branding with gradient background and refresh button
- **Status Card**: System status indicator with process count and visual feedback
- **Process List**: Modern card-based layout showing port badges and process details
- **Action Buttons**: Kill all processes, settings menu, and application controls
- **Footer Menu**: Settings, help documentation, and quit options

### SettingsView
- **Auto-refresh Configuration**: Customizable scan intervals (1-60 seconds)
- **Port Management**: Add/remove custom ports with visual port badges
- **Notification Settings**: Success and error notification preferences
- **Appearance Options**: Theme and display customization
- **Reset to Defaults**: Quick restore to default settings

### Process Management
The application uses a two-stage termination process:
1. **SIGTERM (15)**: Graceful termination request
2. **500ms wait period**: Allow process cleanup
3. **SIGKILL (9)**: Force termination if process still running

### Error Handling
- **Process not found**: Graceful handling of already terminated processes
- **Command execution errors**: User-friendly error messages
- **Permission failures**: Clear guidance for required permissions
- **Network access issues**: Retry mechanisms and status reporting

## 🔄 State Management

### ObservableObject Pattern
```swift
@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var processes: [ProcessInfo] = []
    @Published var isScanning: Bool = false
    @Published var statusInfo: StatusBarInfo
    @Published var settings: AppSettings
    
    // Core functionality
    func refreshProcesses() async
    func killProcess(_ process: ProcessInfo) async
    func killAllProcesses() async
    func startAutoRefresh()
}
```

### Combine Integration
- **Service to ViewModel**: Automatic data flow from backend services
- **Reactive UI Updates**: SwiftUI automatically reflects state changes
- **Error State Management**: Centralized error handling and user feedback

## 🧪 Testing

### Unit Tests
```bash
cd swift-frontend

# Run all tests
xcodebuild test -project swift-frontend.xcodeproj \
                -scheme swift-frontend

# Run specific test class
xcodebuild test -project swift-frontend.xcodeproj \
                -scheme swift-frontend \
                -only-testing:swift-frontendTests/MenuBarViewModelTests
```

### Manual Testing Scenarios

#### Test Process Detection
```bash
# Terminal 1: Start test server
python3 -m http.server 3000

# Terminal 2: Run application and verify detection
# Check that process appears in the monitoring panel
```

#### Test Process Termination
1. Start multiple servers on different ports
2. Open Port Monitor panel
3. Verify all processes are listed
4. Test individual process termination
5. Test bulk process termination

### UI Testing
```bash
# Run UI automation tests
xcodebuild test -project swift-frontend.xcodeproj \
                -scheme swift-frontend \
                -only-testing:swift-frontendUITests
```

## 📁 Project Structure

```
swift-frontend/
├── swift-frontend/
│   ├── swift_frontendApp.swift       # Application entry point
│   ├── ContentView.swift             # Placeholder root view
│   ├── Models/
│   │   ├── ProcessInfo.swift         # Process data structure
│   │   └── StatusBarInfo.swift       # Status information model
│   ├── ViewModels/
│   │   └── MenuBarViewModel.swift    # Main business logic
│   ├── Views/
│   │   ├── MenuBarView.swift         # Primary UI components
│   │   └── SettingsView.swift        # Configuration interface
│   ├── Services/
│   │   └── PortKillService.swift     # Backend communication
│   ├── Managers/
│   │   └── MenuBarManager.swift      # Menu bar integration
│   └── Assets.xcassets/              # UI assets and icons
├── swift-frontendTests/              # Unit tests
├── swift-frontendUITests/            # UI automation tests
└── swift-frontend.xcodeproj/         # Xcode project configuration
```

## 🔮 Planned Enhancements

### Near-term Features
- [ ] **Enhanced Settings Panel**: Advanced port configuration and monitoring options
- [ ] **Notification System**: Native macOS notifications for process events
- [ ] **Keyboard Shortcuts**: Quick access hotkeys for common operations
- [ ] **Process Filtering**: Search and filter capabilities for large process lists
- [ ] **Themes Support**: Light/dark theme customization

### Long-term Goals
- [ ] **Performance Monitoring**: CPU and memory usage tracking for processes
- [ ] **Process History**: Historical view of terminated processes
- [ ] **Integration APIs**: External tool integration capabilities
- [ ] **Advanced Automation**: Scripting support for automated workflows
- [ ] **Multi-user Support**: Process management across different user accounts

## 🐛 Known Issues and Limitations

### Current Limitations
- **Sandbox restrictions**: Some system commands may be limited in sandboxed mode
- **Admin privileges**: Process termination may require elevated permissions for system processes
- **Menu bar icon updates**: Theme changes may require application restart for icon updates
- **Process detection latency**: 2-second default scan interval for real-time updates

### Workarounds
- **Permission issues**: Run application with appropriate user privileges
- **Process not found**: Processes may terminate between scan and kill operations (handled gracefully)
- **UI responsiveness**: All backend operations are asynchronous to prevent UI blocking

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please see the main project's [Contributing Guidelines](../CONTRIBUTING.md) for details on:

1. **Code Style**: Swift and SwiftUI best practices
2. **Testing Requirements**: Unit and UI test coverage expectations
3. **Pull Request Process**: Branch strategy and review process
4. **Issue Reporting**: Bug reports and feature requests

### Development Setup
1. Fork the repository
2. Clone your fork locally
3. Open `swift-frontend.xcodeproj` in Xcode
4. Make your changes with appropriate tests
5. Submit a pull request

---

**Note**: This Swift frontend is designed to work in conjunction with the Zig backend. For complete functionality, ensure both components are properly built and integrated. See the main project [Development Guide](../docs/DEVELOPMENT.md) for full setup instructions.

## 🔄 Data Flow and Communication

### Backend Integration
The Swift frontend communicates with the Zig backend through process execution and JSON data exchange:

```swift
// Swift service layer
class PortKillService: ObservableObject {
    func scanPorts() async -> [ProcessInfo] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "./zig-out/bin/port-kill")
        process.arguments = ["--scan", "--json"]
        
        // Execute and parse response
        let output = try await executeProcess(process)
        return try JSONDecoder().decode([ProcessInfo].self, from: output)
    }
    
    func killProcess(pid: Int) async -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "./zig-out/bin/port-kill")
        process.arguments = ["--kill", "\(pid)"]
        
        return try await executeProcess(process) != nil
    }
}
```

### State Synchronization
- **Real-time updates**: 2-second automatic refresh cycle
- **Reactive UI**: SwiftUI automatically reflects data changes
- **Error handling**: Comprehensive error states and user feedback
- **Performance optimization**: Only update UI when data actually changes

## 🎨 User Interface Design

### Design Principles
- **Minimalist aesthetic**: Clean, uncluttered interface following macOS design guidelines
- **Visual hierarchy**: Clear information structure with appropriate typography and spacing
- **Accessibility**: VoiceOver support, keyboard navigation, and high contrast compatibility
- **Animation**: Smooth, purposeful animations that enhance user experience without distraction

### Color Scheme and Theming
```swift
// Modern gradient implementations
struct GradientStyles {
    static let header = LinearGradient(
        colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let killButton = LinearGradient(
        colors: [.red.opacity(0.8), .pink.opacity(0.6)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let processCard = LinearGradient(
        colors: [.primary.opacity(0.05), .secondary.opacity(0.02)],
        startPoint: .top,
        endPoint: .bottom
    )
}
```

### Component Architecture
- **Reusable components**: Modular UI elements for consistent design
- **Custom modifiers**: SwiftUI view modifiers for common styling patterns
- **Responsive design**: Adapts to different content sizes and system settings
- **System integration**: Uses native macOS UI patterns and behaviors
