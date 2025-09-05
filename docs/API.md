# Port Kill Monitor - API Reference

This document provides comprehensive API documentation for both the Swift frontend and Zig backend components of Port Kill Monitor.

## 🍎 Swift Frontend API

### Core Models

#### ProcessInfo
```swift
struct ProcessInfo: Identifiable, Codable {
    let id: UUID = UUID()
    let pid: Int
    let port: Int
    let name: String
    let command: String
    let user: String?
    
    // Computed properties
    var displayName: String { /* Returns formatted process name */ }
    var commandPath: String { /* Returns executable path */ }
    var isSystemProcess: Bool { /* Checks if system-owned */ }
}
```

#### StatusBarInfo
```swift
struct StatusBarInfo {
    let processCount: Int
    let lastScanTime: Date
    let status: ScanStatus
    let errorMessage: String?
    
    enum ScanStatus {
        case idle
        case scanning
        case error(String)
        case success
    }
}
```

#### AppSettings
```swift
struct AppSettings: Codable {
    var autoRefreshInterval: TimeInterval = 2.0
    var monitoredPorts: [Int] = [3000, 4000, 5000, 8000, 8080, 8888, 9000]
    var showNotifications: Bool = true
    var enableVerboseLogging: Bool = false
    var theme: AppTheme = .system
    
    enum AppTheme: String, CaseIterable, Codable {
        case light, dark, system
    }
}
```

### ViewModels

#### MenuBarViewModel
```swift
@MainActor
class MenuBarViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var processes: [ProcessInfo] = []
    @Published private(set) var isScanning: Bool = false
    @Published private(set) var statusInfo: StatusBarInfo
    @Published var settings: AppSettings
    @Published private(set) var lastError: Error?
    
    // MARK: - Public Methods
    
    /// Manually refresh the process list
    func refreshProcesses() async
    
    /// Kill a specific process by ProcessInfo
    /// - Parameter process: The process to terminate
    /// - Returns: Success status
    func killProcess(_ process: ProcessInfo) async -> Bool
    
    /// Kill a specific process by PID
    /// - Parameter pid: Process ID to terminate
    /// - Returns: Success status
    func killProcessByPID(_ pid: Int) async -> Bool
    
    /// Kill all monitored processes
    /// - Returns: Number of processes successfully terminated
    func killAllProcesses() async -> Int
    
    /// Start automatic refresh with current settings
    func startAutoRefresh()
    
    /// Stop automatic refresh
    func stopAutoRefresh()
    
    /// Update monitoring settings
    /// - Parameter newSettings: Updated settings configuration
    func updateSettings(_ newSettings: AppSettings)
    
    /// Export current process list
    /// - Returns: JSON representation of processes
    func exportProcessList() -> Data?
    
    /// Import process configuration
    /// - Parameter data: JSON data to import
    /// - Returns: Success status
    func importConfiguration(from data: Data) -> Bool
}
```

### Services

#### PortKillService
```swift
class PortKillService: ObservableObject {
    // MARK: - Configuration
    struct ServiceConfiguration {
        let backendPath: String
        let timeout: TimeInterval
        let retryCount: Int
        let verboseLogging: Bool
    }
    
    // MARK: - Public Methods
    
    /// Scan ports for active processes
    /// - Parameter ports: Array of ports to scan (nil for all monitored ports)
    /// - Returns: Array of detected processes
    func scanPorts(_ ports: [Int]? = nil) async throws -> [ProcessInfo]
    
    /// Kill process by PID
    /// - Parameter pid: Process ID to terminate
    /// - Returns: Success status
    func killProcess(pid: Int) async throws -> Bool
    
    /// Get system status information
    /// - Returns: Current system status
    func getSystemStatus() async throws -> StatusBarInfo
    
    /// Execute custom backend command
    /// - Parameters:
    ///   - command: Command to execute
    ///   - arguments: Command arguments
    /// - Returns: Command output
    func executeCommand(_ command: String, arguments: [String]) async throws -> String
    
    /// Validate backend availability
    /// - Returns: Backend availability status
    func validateBackend() async -> Bool
    
    /// Get backend version information
    /// - Returns: Version string
    func getBackendVersion() async throws -> String
}
```

### Views

#### MenuBarView
```swift
struct MenuBarView: View {
    @StateObject private var viewModel: MenuBarViewModel
    @State private var showingSettings = false
    @State private var showingAbout = false
    
    var body: some View {
        // Implementation details...
    }
    
    // MARK: - View Components
    
    /// Header section with app branding
    @ViewBuilder
    private var headerSection: some View
    
    /// Status information card
    @ViewBuilder
    private var statusSection: some View
    
    /// Process list with cards
    @ViewBuilder
    private var processListSection: some View
    
    /// Action buttons section
    @ViewBuilder
    private var actionButtonsSection: some View
    
    /// Footer menu section
    @ViewBuilder
    private var footerSection: some View
}
```

#### SettingsView
```swift
struct SettingsView: View {
    @Binding var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Implementation details...
    }
    
    // MARK: - Settings Sections
    
    /// Auto-refresh configuration
    @ViewBuilder
    private var refreshSettings: some View
    
    /// Port management interface
    @ViewBuilder
    private var portSettings: some View
    
    /// Notification preferences
    @ViewBuilder
    private var notificationSettings: some View
    
    /// Appearance and theme options
    @ViewBuilder
    private var appearanceSettings: some View
}
```

## ⚡ Zig Backend API

### Core Types

#### ProcessInfo
```zig
pub const ProcessInfo = struct {
    pid: u32,
    port: u16,
    name: []const u8,
    command: []const u8,
    user: ?[]const u8,
    
    /// Initialize ProcessInfo with allocated strings
    pub fn init(allocator: std.mem.Allocator, pid: u32, port: u16, name: []const u8, command: []const u8, user: ?[]const u8) !ProcessInfo
    
    /// Clean up allocated memory
    pub fn deinit(self: ProcessInfo, allocator: std.mem.Allocator) void
    
    /// Custom formatter for display
    pub fn format(self: ProcessInfo, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void
    
    /// Convert to JSON object
    pub fn toJSON(self: ProcessInfo, writer: anytype) !void
};
```

#### MonitorConfig
```zig
pub const MonitorConfig = struct {
    start_port: u16 = 2000,
    end_port: u16 = 6000,
    specific_ports: ?[]const u16 = null,
    scan_interval: u32 = 2000, // milliseconds
    verbose: bool = false,
    json_output: bool = false,
    continuous_scan: bool = true,
    
    /// Validate configuration parameters
    pub fn validate(self: MonitorConfig) !void
    
    /// Get effective port list
    pub fn getPortList(self: MonitorConfig, allocator: std.mem.Allocator) ![]u16
};
```

### Process Monitor

#### ProcessMonitor
```zig
pub const ProcessMonitor = struct {
    allocator: std.mem.Allocator,
    config: MonitorConfig,
    
    /// Initialize process monitor
    pub fn init(allocator: std.mem.Allocator, config: MonitorConfig) ProcessMonitor
    
    /// Clean up resources
    pub fn deinit(self: *ProcessMonitor) void
    
    /// Scan all configured ports for processes
    pub fn scanPorts(self: *ProcessMonitor) ![]ProcessInfo
    
    /// Scan a specific port
    pub fn scanSinglePort(self: *ProcessMonitor, port: u16) !?ProcessInfo
    
    /// Kill process by PID
    pub fn killProcess(self: *ProcessMonitor, pid: u32) !bool
    
    /// Kill all processes on monitored ports
    pub fn killAllProcesses(self: *ProcessMonitor) !u32
    
    /// Check if process is still running
    pub fn isProcessRunning(self: *ProcessMonitor, pid: u32) bool
    
    /// Get detailed process information
    pub fn getProcessDetails(self: *ProcessMonitor, pid: u32) !ProcessInfo
    
    /// Export scan results to JSON
    pub fn exportToJSON(self: *ProcessMonitor, processes: []const ProcessInfo, writer: anytype) !void
    
    /// Get monitor statistics
    pub fn getStatistics(self: *ProcessMonitor) MonitorStatistics
};
```

#### MonitorStatistics
```zig
pub const MonitorStatistics = struct {
    total_scans: u64,
    processes_found: u64,
    processes_killed: u64,
    scan_duration_avg: u64, // microseconds
    last_scan_time: i64,    // unix timestamp
    error_count: u64,
    
    pub fn format(self: MonitorStatistics, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void
};
```

### CLI Interface

#### CliArgs
```zig
pub const CliArgs = struct {
    start_port: u16 = 2000,
    end_port: u16 = 6000,
    specific_ports: ?[]const u16 = null,
    console_mode: bool = false,
    verbose: bool = false,
    json_output: bool = false,
    scan_once: bool = false,
    kill_pid: ?u32 = null,
    kill_all: bool = false,
    show_help: bool = false,
    show_version: bool = false,
    scan_interval: u32 = 2000,
    
    /// Parse command line arguments
    pub fn parse(allocator: std.mem.Allocator) !CliArgs
    
    /// Validate parsed arguments
    pub fn validate(self: CliArgs) !void
    
    /// Print usage information
    pub fn printUsage(writer: anytype) !void
    
    /// Print version information
    pub fn printVersion(writer: anytype) !void
};
```

### Applications

#### ConsoleApp
```zig
pub const ConsoleApp = struct {
    monitor: ProcessMonitor,
    args: CliArgs,
    
    /// Initialize console application
    pub fn init(allocator: std.mem.Allocator, args: CliArgs) !ConsoleApp
    
    /// Run the console application
    pub fn run(self: *ConsoleApp) !void
    
    /// Run single scan and exit
    pub fn runOnce(self: *ConsoleApp) !void
    
    /// Run continuous monitoring
    pub fn runContinuous(self: *ConsoleApp) !void
    
    /// Handle kill commands
    pub fn handleKillCommand(self: *ConsoleApp) !void
    
    /// Print scan results
    pub fn printResults(self: *ConsoleApp, processes: []const ProcessInfo) !void
};
```

#### TrayApp
```zig
pub const TrayApp = struct {
    monitor: ProcessMonitor,
    status_item: objc.id,
    menu: objc.id,
    
    /// Initialize system tray application
    pub fn init(allocator: std.mem.Allocator, config: MonitorConfig) !TrayApp
    
    /// Start the application event loop
    pub fn run(self: *TrayApp) !void
    
    /// Update menu with current processes
    pub fn updateMenu(self: *TrayApp, processes: []const ProcessInfo) !void
    
    /// Handle menu item selection
    pub fn handleMenuAction(self: *TrayApp, action: MenuAction) !void
    
    /// Clean up system resources
    pub fn deinit(self: *TrayApp) void
};

pub const MenuAction = enum {
    refresh,
    kill_process,
    kill_all,
    show_settings,
    quit,
};
```

## 🔄 Communication Protocol

### JSON Data Format

#### Process List Response
```json
{
  "timestamp": "2025-09-05T10:30:45Z",
  "scan_duration_ms": 150,
  "process_count": 3,
  "processes": [
    {
      "pid": 12345,
      "port": 3000,
      "name": "node",
      "command": "/usr/local/bin/node server.js",
      "user": "developer"
    },
    {
      "pid": 12346,
      "port": 8000,
      "name": "python3",
      "command": "python3 -m http.server 8000",
      "user": "developer"
    }
  ]
}
```

#### Kill Process Response
```json
{
  "success": true,
  "pid": 12345,
  "signal_sent": "SIGTERM",
  "termination_time_ms": 250,
  "message": "Process terminated successfully"
}
```

#### Error Response
```json
{
  "success": false,
  "error_code": "PERMISSION_DENIED",
  "error_message": "Insufficient privileges to terminate process",
  "details": {
    "pid": 12345,
    "required_permission": "process_management"
  }
}
```

### Command Line Interface

#### Scan Commands
```bash
# Basic scan
./port-kill-console --scan

# Scan specific ports
./port-kill-console --ports 3000,8000,8080 --json

# Scan port range
./port-kill-console --start-port 3000 --end-port 5000

# Single scan with verbose output
./port-kill-console --scan-once --verbose
```

#### Kill Commands
```bash
# Kill specific process
./port-kill-console --kill-pid 12345

# Kill all monitored processes
./port-kill-console --kill-all

# Kill with confirmation
./port-kill-console --kill-pid 12345 --confirm
```

#### Monitoring Commands
```bash
# Continuous monitoring
./port-kill-console --monitor --interval 1000

# Monitor with auto-kill
./port-kill-console --monitor --auto-kill --ports 3000,8000
```

## 🔧 Error Handling

### Swift Error Types
```swift
enum PortKillError: LocalizedError {
    case backendNotFound
    case commandExecutionFailed(String)
    case invalidProcessInfo
    case permissionDenied
    case processNotFound(Int)
    case scanTimeout
    case configurationInvalid
    
    var errorDescription: String? {
        switch self {
        case .backendNotFound:
            return "Zig backend executable not found"
        case .commandExecutionFailed(let command):
            return "Failed to execute command: \(command)"
        case .invalidProcessInfo:
            return "Invalid process information received"
        case .permissionDenied:
            return "Permission denied for process operation"
        case .processNotFound(let pid):
            return "Process with PID \(pid) not found"
        case .scanTimeout:
            return "Process scan timed out"
        case .configurationInvalid:
            return "Invalid configuration settings"
        }
    }
}
```

### Zig Error Types
```zig
pub const MonitorError = error{
    ProcessNotFound,
    PermissionDenied,
    CommandFailed,
    InvalidPort,
    SystemResourceExhausted,
    ParseError,
    TimeoutError,
    ConfigurationError,
    BackendError,
};

pub fn errorToString(err: MonitorError) []const u8 {
    return switch (err) {
        MonitorError.ProcessNotFound => "Process not found",
        MonitorError.PermissionDenied => "Permission denied",
        MonitorError.CommandFailed => "Command execution failed",
        MonitorError.InvalidPort => "Invalid port number",
        MonitorError.SystemResourceExhausted => "System resources exhausted",
        MonitorError.ParseError => "Failed to parse command output",
        MonitorError.TimeoutError => "Operation timed out",
        MonitorError.ConfigurationError => "Invalid configuration",
        MonitorError.BackendError => "Backend system error",
    };
}
```

## 📊 Performance Metrics

### Benchmarking API
```zig
pub const PerformanceMetrics = struct {
    scan_time_ns: u64,
    process_count: u32,
    memory_used_bytes: u64,
    cpu_usage_percent: f32,
    
    pub fn benchmark(monitor: *ProcessMonitor, iterations: u32) !PerformanceMetrics
    pub fn format(self: PerformanceMetrics, writer: anytype) !void
};
```

### Monitoring Statistics
```swift
struct MonitoringStatistics {
    let totalScans: Int
    let averageScanTime: TimeInterval
    let processesDetected: Int
    let processesTerminated: Int
    let errorCount: Int
    let uptime: TimeInterval
    
    func export() -> Data?
    static func import(from data: Data) -> MonitoringStatistics?
}
```

---

This API reference provides comprehensive documentation for integrating with and extending the Port Kill Monitor application. For implementation examples and usage patterns, see the [Development Guide](DEVELOPMENT.md) and [Architecture Guide](ARCHITECTURE.md).
