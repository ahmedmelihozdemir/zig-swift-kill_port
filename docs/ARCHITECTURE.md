# Port Kill Monitor - Technical Architecture

This document provides detailed technical information about the Port Kill Monitor application architecture, covering both the Swift frontend and Zig backend components.

## 🏗️ Overall Architecture

Port Kill Monitor follows a clean separation of concerns with a modern Swift frontend communicating with a high-performance Zig backend.

```
┌─────────────────────────────────────────────────────────┐
│                    macOS Menu Bar                       │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│               Swift Frontend                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐│
│  │    Views    │ │ ViewModels  │ │     Services        ││
│  │  (SwiftUI)  │ │   (MVVM)    │ │ (Communication)     ││
│  └─────────────┘ └─────────────┘ └─────────────────────┘│
└─────────────────────┬───────────────────────────────────┘
                      │ Process Communication
┌─────────────────────▼───────────────────────────────────┐
│                Zig Backend                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐│
│  │   Monitor   │ │  CLI Tools  │ │  System Integration ││
│  │   Engine    │ │   (Console) │ │    (lsof, kill)     ││
│  └─────────────┘ └─────────────┘ └─────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

## 🍎 Swift Frontend Architecture

### MVVM (Model-View-ViewModel) Pattern

The Swift frontend follows the MVVM architectural pattern for clean separation and testability.

#### Models
Location: `swift-frontend/swift-frontend/Models/`

**ProcessInfo.swift**
```swift
struct ProcessInfo: Identifiable, Codable {
    let id = UUID()
    let pid: Int
    let port: Int
    let name: String
    let command: String
    let user: String?
    
    // Custom formatting and utility methods
    var displayName: String
    var commandPath: String
}
```

**StatusBarInfo.swift**
```swift
struct StatusBarInfo {
    let processCount: Int
    let lastScanTime: Date
    let status: ScanStatus
    let errorMessage: String?
    
    enum ScanStatus {
        case idle, scanning, error, success
    }
}
```

#### ViewModels
Location: `swift-frontend/swift-frontend/ViewModels/`

**MenuBarViewModel.swift**
```swift
@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var processes: [ProcessInfo] = []
    @Published var isScanning: Bool = false
    @Published var statusInfo: StatusBarInfo
    @Published var settings: AppSettings
    
    // Business logic methods
    func refreshProcesses()
    func killProcess(_ process: ProcessInfo)
    func killAllProcesses()
    func startAutoRefresh()
    func stopAutoRefresh()
}
```

#### Views
Location: `swift-frontend/swift-frontend/Views/`

**MenuBarView.swift** - Main popover interface
- Header section with app branding
- Status display with visual indicators
- Process list with modern card design
- Action buttons for operations
- Settings and menu integration

**SettingsView.swift** - Configuration interface
- Auto-refresh interval settings
- Port configuration management
- Notification preferences
- Theme and appearance options

#### Services
Location: `swift-frontend/swift-frontend/Services/`

**PortKillService.swift**
```swift
class PortKillService: ObservableObject {
    // Backend communication
    func scanPorts() async -> [ProcessInfo]
    func killProcess(pid: Int) async -> Bool
    func getSystemStatus() async -> StatusBarInfo
    
    // Command execution
    private func executeCommand(_ command: String) -> String
    private func parseProcessOutput(_ output: String) -> [ProcessInfo]
}
```

#### Managers
Location: `swift-frontend/swift-frontend/Managers/`

**MenuBarManager.swift**
- NSStatusBar integration
- Popover management
- Menu bar icon updates
- System event handling

### UI/UX Design Principles

#### Color Scheme
```swift
// Modern gradient colors
let headerGradient = LinearGradient(
    colors: [.blue, .purple],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

let killButtonGradient = LinearGradient(
    colors: [.red, .pink],
    startPoint: .leading,
    endPoint: .trailing
)
```

#### Animations
- Smooth 0.3s easeInOut transitions
- Rotation animations for refresh button
- Scale effects for button interactions
- Fade transitions for content changes

#### Accessibility
- VoiceOver support for all interactive elements
- Keyboard navigation support
- High contrast color support
- Semantic content descriptions

## ⚡ Zig Backend Architecture

### Performance-First Design

The Zig backend is designed for minimal overhead and maximum performance.

#### Module Structure
```
zig-backend/src/
├── main.zig                 # GUI mode entry point
├── main_console.zig         # Console mode entry point
├── lib/                     # Core library modules
│   ├── types.zig           # Data structures
│   ├── process_monitor.zig # Process monitoring logic
│   └── cli.zig             # Command line parsing
└── apps/                   # Application modules
    ├── console_app.zig     # Console application
    └── tray_app.zig        # System tray application
```

#### Core Types (types.zig)
```zig
const ProcessInfo = struct {
    pid: u32,
    port: u16,
    name: []const u8,
    command: []const u8,
    user: ?[]const u8,
    
    pub fn format(self: ProcessInfo, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        // Custom formatting implementation
    }
};

const MonitorConfig = struct {
    start_port: u16 = 2000,
    end_port: u16 = 6000,
    specific_ports: ?[]const u16 = null,
    scan_interval: u32 = 2000, // milliseconds
    verbose: bool = false,
};
```

#### Process Monitoring (process_monitor.zig)
```zig
pub const ProcessMonitor = struct {
    allocator: std.mem.Allocator,
    config: MonitorConfig,
    
    pub fn init(allocator: std.mem.Allocator, config: MonitorConfig) ProcessMonitor {
        return ProcessMonitor{
            .allocator = allocator,
            .config = config,
        };
    }
    
    pub fn scanPorts(self: *ProcessMonitor) ![]ProcessInfo {
        // Implementation using lsof command
        return try self.executePortScan();
    }
    
    pub fn killProcess(self: *ProcessMonitor, pid: u32) !bool {
        // SIGTERM -> wait -> SIGKILL implementation
        return try self.terminateProcess(pid);
    }
    
    fn executePortScan(self: *ProcessMonitor) ![]ProcessInfo {
        // Execute: lsof -ti :PORT -sTCP:LISTEN
        // Parse output and return ProcessInfo array
    }
    
    fn terminateProcess(self: *ProcessMonitor, pid: u32) !bool {
        // 1. Send SIGTERM (15)
        // 2. Wait 500ms
        // 3. Send SIGKILL (9) if still running
    }
};
```

#### CLI Interface (cli.zig)
```zig
pub const CliArgs = struct {
    start_port: u16 = 2000,
    end_port: u16 = 6000,
    specific_ports: ?[]const u16 = null,
    console_mode: bool = false,
    verbose: bool = false,
    help: bool = false,
    version: bool = false,
    
    pub fn parse(allocator: std.mem.Allocator) !CliArgs {
        // Command line argument parsing implementation
    }
};
```

### System Integration

#### macOS Native APIs
The Zig backend integrates directly with macOS system APIs:

```zig
// Direct system call integration
const c = @cImport({
    @cInclude("unistd.h");
    @cInclude("signal.h");
    @cInclude("sys/wait.h");
});

fn sendSignal(pid: u32, signal: c_int) !void {
    const result = c.kill(@intCast(c.pid_t, pid), signal);
    if (result != 0) {
        return error.SignalFailed;
    }
}
```

#### Process Detection
Uses `lsof` command for efficient process detection:
```bash
lsof -ti :PORT -sTCP:LISTEN
```

#### Process Termination Strategy
1. **SIGTERM (15)**: Graceful termination request
2. **500ms wait**: Allow process to clean up
3. **SIGKILL (9)**: Force termination if needed

## 🔄 Communication Protocol

### Frontend to Backend Communication

The Swift frontend communicates with the Zig backend through process execution:

```swift
// Swift side
func scanPorts() async -> [ProcessInfo] {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "./zig-out/bin/port-kill")
    process.arguments = ["--scan", "--json"]
    
    // Execute and parse JSON response
    let output = try await process.run()
    return try JSONDecoder().decode([ProcessInfo].self, from: output)
}
```

```zig
// Zig side - JSON output
pub fn outputJSON(processes: []ProcessInfo, writer: anytype) !void {
    try std.json.stringify(processes, .{}, writer);
}
```

### Data Serialization

Both components use JSON for data exchange:
- **Process lists**: Serialized as JSON arrays
- **Status information**: JSON objects with metadata
- **Error reporting**: Standardized error JSON format

## 🧪 Testing Architecture

### Swift Tests
Location: `swift-frontend/swift-frontendTests/`

```swift
class MenuBarViewModelTests: XCTestCase {
    func testProcessScanning() async {
        let viewModel = MenuBarViewModel()
        await viewModel.refreshProcesses()
        // Test assertions
    }
    
    func testProcessKilling() async {
        // Test process termination
    }
}
```

### Zig Tests
Location: `zig-backend/test/`

```zig
const testing = std.testing;

test "process monitor initialization" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    
    const monitor = ProcessMonitor.init(gpa.allocator(), .{});
    try testing.expect(monitor.config.start_port == 2000);
}

test "port scanning functionality" {
    // Test port scanning logic
}
```

## 🚀 Performance Considerations

### Swift Frontend Optimizations
- **@MainActor** usage for UI thread safety
- **Async/await** for non-blocking operations
- **Combine** for reactive data binding
- **Memory management** with ARC

### Zig Backend Optimizations
- **Zero-cost abstractions** where possible
- **Minimal memory allocations** during scanning
- **Efficient string processing** for command output
- **Direct system calls** to avoid overhead

### Memory Usage
- **Swift Frontend**: ~10-15 MB typical usage
- **Zig Backend**: ~1-2 MB for core operations
- **Total System Impact**: Minimal, designed for continuous operation

## 🔒 Security Considerations

### Permission Requirements
- **Terminal access**: Required for `lsof` and `kill` commands
- **Process management**: Ability to terminate user processes
- **No network access**: All operations are local

### Sandboxing
- **Swift app**: Runs with minimal permissions
- **Zig backend**: Requires process management capabilities
- **User consent**: All operations require explicit user action

### Safe Operation
- **Confirmation dialogs** for critical operations
- **Process validation** before termination
- **Error handling** for permission failures
- **Graceful degradation** when permissions unavailable

## 🔮 Future Architecture Enhancements

### Planned Improvements
1. **IPC optimization**: Direct memory-mapped communication
2. **Plugin system**: Extensible monitoring capabilities
3. **Configuration management**: Persistent settings storage
4. **Advanced filtering**: Process categorization and filtering
5. **Performance monitoring**: CPU and memory usage tracking

### Scalability Considerations
- **Modular design** allows easy feature additions
- **Clean interfaces** between components
- **Testable architecture** ensures quality
- **Documentation-driven** development process

---

This architecture provides a solid foundation for a performant, maintainable, and extensible macOS application that efficiently monitors and manages development processes.
