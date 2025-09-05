# Port Kill Monitor - Zig Backend

High-performance system monitoring backend built with Zig 0.15.1 for efficient process detection and management on macOS. Provides both GUI integration and standalone console utilities.

![Zig](https://img.shields.io/badge/Zig-0.15+-yellow) ![macOS](https://img.shields.io/badge/macOS-Native-blue) ![Performance](https://img.shields.io/badge/Performance-Optimized-green)

## 🚀 Features

- **High-Performance Monitoring**: Efficient process scanning with minimal system overhead
- **Dual Interface Support**: Both system tray integration and console mode operation
- **Flexible Port Configuration**: Monitor port ranges or specific ports with custom settings
- **macOS Native Integration**: Direct system API integration using Cocoa frameworks
- **Memory Efficient**: Minimal memory footprint with careful resource management
- **Fast Compilation**: Leverages Zig's fast compilation for rapid development cycles

## 📋 System Requirements

- **Operating System**: macOS 10.15 (Catalina) or later
- **Architecture**: Intel x64 or Apple Silicon (M1/M2/M3)
- **Zig Compiler**: 0.15.0 or later
- **System Tools**: `lsof` command (included with macOS)
- **Permissions**: Process management capabilities

## ⚡ Quick Start

### Installation and Setup

#### Method 1: Quick Build and Run
```bash
# Clone the repository
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port/zig-backend

# Build and run with convenience script
./scripts/run.sh
```

#### Method 2: Manual Build Process
```bash
# Navigate to backend directory
cd zig-backend

# Build optimized binaries
zig build -Doptimize=ReleaseFast

# Run GUI mode
./zig-out/bin/port-kill

# Run console mode
./zig-out/bin/port-kill-console
```

## 🎯 Usage Examples

### Basic Operation
```bash
# Default monitoring (ports 2000-6000, GUI mode)
./scripts/run.sh

# Console mode with default settings
./scripts/run.sh --console

# Verbose logging for debugging
./scripts/run.sh --verbose --console
```

### Port Configuration
```bash
# Monitor specific port range
./scripts/run.sh --start-port 3000 --end-port 8080

# Monitor only specific ports
./scripts/run.sh --ports 3000,8000,8080,5000

# Combine with console mode
./scripts/run.sh --console --ports 3000,8000,8080
```

### Advanced Usage
```bash
# JSON output for integration with other tools
./zig-out/bin/port-kill-console --json --scan-once

# Continuous monitoring with custom interval
./zig-out/bin/port-kill-console --interval 1000 --verbose

# Kill specific process by PID
./zig-out/bin/port-kill-console --kill-pid 12345
```

## ⚙️ Command Line Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--start-port` | `-s` | Starting port for range monitoring | 2000 |
| `--end-port` | `-e` | Ending port for range monitoring | 6000 |
| `--ports` | `-p` | Specific ports (comma-separated) | None |
| `--console` | `-c` | Run in console mode | GUI mode |
| `--verbose` | `-v` | Enable verbose logging | Disabled |
| `--json` | `-j` | Output in JSON format | Text format |
| `--scan-once` | | Scan once and exit | Continuous |
| `--interval` | `-i` | Scan interval in milliseconds | 2000 |
| `--kill-pid` | | Kill specific process by PID | None |
| `--help` | `-h` | Show help information | |
| `--version` | `-V` | Show version information | |

## 🧪 Testing and Development

### Running Tests
```bash
# Build and run all tests
zig build test

# Run unit tests with verbose output
zig build test -- --verbose

# Test specific functionality
zig build test-port

# Run example programs
zig run examples/monitor_port.zig
```

### Development Testing Setup
```bash
# Terminal 1: Start test HTTP servers on multiple ports
./scripts/test_ports.sh

# Terminal 2: Run the backend in verbose console mode
./scripts/run.sh --console --verbose

# Terminal 3: Test specific functionality
./zig-out/bin/port-kill-console --ports 3000,8000,8080
```

### Debugging and Profiling
```bash
# Build with debug symbols
zig build -Doptimize=Debug

# Run with memory checking
zig build -Doptimize=Debug -Dcheck-memory

# Profile performance
time ./zig-out/bin/port-kill-console --scan-once
```

## 🏗️ Architecture and Implementation

### Zig 0.15.1 Modern Features

This implementation leverages the latest Zig features for optimal performance:

#### Advanced Language Features
```zig
// New std.fmt API with custom formatters
pub fn format(self: ProcessInfo, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    try writer.print("Process(pid={}, port={}, name={})", .{ self.pid, self.port, self.name });
}

// Unmanaged ArrayLists for memory control
var processes = std.ArrayListUnmanaged(ProcessInfo){};
defer processes.deinit(allocator);

// Compile-time string processing
const command_template = comptime std.fmt.comptimePrint("lsof -ti :{} -sTCP:LISTEN", .{});
```

#### Error Handling Excellence
```zig
const MonitorError = error{
    ProcessNotFound,
    PermissionDenied,
    CommandFailed,
    InvalidPort,
    SystemResourceExhausted,
};

pub fn scanPorts(self: *ProcessMonitor) MonitorError![]ProcessInfo {
    const output = self.executeCommand() catch |err| switch (err) {
        error.PermissionDenied => return MonitorError.PermissionDenied,
        error.FileNotFound => return MonitorError.CommandFailed,
        else => return err,
    };
    
    return self.parseOutput(output);
}
```

### Module Organization

```
src/
├── main.zig                 # GUI application entry point
├── main_console.zig         # Console application entry point
├── lib/                     # Core library modules
│   ├── types.zig           # Data structures and type definitions
│   ├── process_monitor.zig # Process monitoring core logic
│   └── cli.zig             # Command line argument parsing
├── apps/                   # Application-specific modules
│   ├── console_app.zig     # Console interface implementation
│   └── tray_app.zig        # System tray integration
└── test/                   # Test files and examples
```

#### Core Data Types (types.zig)
```zig
pub const ProcessInfo = struct {
    pid: u32,
    port: u16,
    name: []const u8,
    command: []const u8,
    user: ?[]const u8,
    
    pub fn deinit(self: ProcessInfo, allocator: std.mem.Allocator) void {
        allocator.free(self.name);
        allocator.free(self.command);
        if (self.user) |user| allocator.free(user);
    }
};

pub const MonitorConfig = struct {
    start_port: u16 = 2000,
    end_port: u16 = 6000,
    specific_ports: ?[]const u16 = null,
    scan_interval: u32 = 2000, // milliseconds
    verbose: bool = false,
    json_output: bool = false,
};
```

#### Process Detection Engine (process_monitor.zig)
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
        var processes = std.ArrayListUnmanaged(ProcessInfo){};
        
        if (self.config.specific_ports) |ports| {
            for (ports) |port| {
                try self.scanSinglePort(port, &processes);
            }
        } else {
            var port: u16 = self.config.start_port;
            while (port <= self.config.end_port) : (port += 1) {
                try self.scanSinglePort(port, &processes);
            }
        }
        
        return processes.toOwnedSlice(self.allocator);
    }
    
    fn scanSinglePort(self: *ProcessMonitor, port: u16, processes: *std.ArrayListUnmanaged(ProcessInfo)) !void {
        // Execute: lsof -ti :PORT -sTCP:LISTEN
        const command = try std.fmt.allocPrint(self.allocator, "lsof -ti :{} -sTCP:LISTEN", .{port});
        defer self.allocator.free(command);
        
        const result = std.ChildProcess.exec(.{
            .allocator = self.allocator,
            .argv = &[_][]const u8{ "sh", "-c", command },
        }) catch return;
        
        defer self.allocator.free(result.stdout);
        defer self.allocator.free(result.stderr);
        
        if (result.term.Exited == 0 and result.stdout.len > 0) {
            try self.parseProcessOutput(result.stdout, port, processes);
        }
    }
};
```

### Process Termination Strategy

The backend implements a safe, two-stage process termination:

```zig
pub fn killProcess(self: *ProcessMonitor, pid: u32) !bool {
    // Stage 1: Graceful termination with SIGTERM
    try self.sendSignal(pid, std.os.SIG.TERM);
    
    // Wait period for graceful shutdown
    std.time.sleep(500 * std.time.ns_per_ms);
    
    // Check if process still exists
    if (self.isProcessRunning(pid)) {
        // Stage 2: Force termination with SIGKILL
        try self.sendSignal(pid, std.os.SIG.KILL);
        return true;
    }
    
    return true;
}

fn sendSignal(self: *ProcessMonitor, pid: u32, signal: i32) !void {
    const result = std.os.kill(@intCast(i32, pid), signal);
    if (result != 0) {
        return error.TerminationFailed;
    }
}
```

### macOS System Integration

#### Native Cocoa API Integration
```zig
// Direct system tray integration using Objective-C runtime
const objc = @cImport({
    @cInclude("objc/runtime.h");
    @cInclude("objc/message.h");
    @cInclude("AppKit/AppKit.h");
});

pub const TrayApp = struct {
    status_bar: objc.id,
    status_item: objc.id,
    menu: objc.id,
    
    pub fn init() TrayApp {
        const app = objc.objc_msgSend(objc.objc_getClass("NSApplication"), objc.sel_getUid("sharedApplication"));
        const status_bar = objc.objc_msgSend(objc.objc_getClass("NSStatusBar"), objc.sel_getUid("systemStatusBar"));
        
        return TrayApp{
            .status_bar = status_bar,
            .status_item = undefined,
            .menu = undefined,
        };
    }
};
```

### Performance Characteristics

#### Memory Management
- **Stack allocation preferred**: Minimize heap allocations during monitoring
- **Arena allocators**: Batch allocations for process lists
- **Precise cleanup**: Explicit resource management with defer statements
- **Memory pooling**: Reuse allocations across scan cycles

#### Compilation Performance
```bash
# Zig compilation benchmarks
time zig build -Doptimize=ReleaseFast
# Typical: ~3-5 seconds for full build
# Incremental: ~0.5-1 second

# Binary size comparison
ls -la zig-out/bin/
# port-kill: ~2-3MB (optimized)
# port-kill-console: ~1-2MB
```

## 🔧 Build System and Configuration

### Build.zig Configuration
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    // Main GUI executable
    const exe = b.addExecutable(.{
        .name = "port-kill",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    
    // Console executable
    const console_exe = b.addExecutable(.{
        .name = "port-kill-console",
        .root_source_file = .{ .path = "src/main_console.zig" },
        .target = target,
        .optimize = optimize,
    });
    
    // Link system frameworks for macOS integration
    exe.linkFramework("AppKit");
    exe.linkFramework("Foundation");
    
    b.installArtifact(exe);
    b.installArtifact(console_exe);
    
    // Test configuration
    const test_step = b.step("test", "Run unit tests");
    const lib_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/lib/process_monitor.zig" },
        .target = target,
        .optimize = optimize,
    });
    test_step.dependOn(&b.addRunArtifact(lib_tests).step);
}
```

### Optimization Levels
```bash
# Debug build - development and debugging
zig build -Doptimize=Debug

# Release builds with different optimization strategies
zig build -Doptimize=ReleaseFast    # Optimize for speed
zig build -Doptimize=ReleaseSmall   # Optimize for size
zig build -Doptimize=ReleaseSafe    # Optimize with safety checks
```

## 🔄 Integration with Swift Frontend

### Communication Protocol
The Zig backend provides JSON output for seamless integration:

```zig
pub fn outputJSON(processes: []const ProcessInfo, writer: anytype) !void {
    try writer.writeAll("[\n");
    for (processes, 0..) |process, i| {
        if (i > 0) try writer.writeAll(",\n");
        try writer.print("  {{\n", .{});
        try writer.print("    \"pid\": {},\n", .{process.pid});
        try writer.print("    \"port\": {},\n", .{process.port});
        try writer.print("    \"name\": \"{s}\",\n", .{process.name});
        try writer.print("    \"command\": \"{s}\",\n", .{process.command});
        try writer.print("    \"user\": \"{s}\"\n", .{process.user orelse "unknown"});
        try writer.print("  }}", .{});
    }
    try writer.writeAll("\n]\n");
}
```

### Command Interface
```bash
# Swift frontend calls
./zig-out/bin/port-kill --scan --json          # Get process list
./zig-out/bin/port-kill --kill --pid 1234      # Terminate process
./zig-out/bin/port-kill --status               # Get system status
```

## 🔮 Future Development

### Planned Enhancements
1. **Enhanced System Integration**: Deeper macOS integration with native notifications
2. **Advanced Process Analysis**: CPU, memory usage monitoring integration
3. **Configuration Management**: Persistent settings and profile support
4. **Plugin Architecture**: Extensible monitoring capabilities
5. **Network Protocol Support**: Monitor network connections beyond just ports

### Performance Goals
- **Sub-millisecond scanning**: Further optimize process detection algorithms
- **Memory efficiency**: Reduce memory footprint to < 1MB for console version
- **Battery optimization**: Minimize CPU usage during continuous monitoring
- **Scalability**: Support monitoring hundreds of ports simultaneously

## 📄 License and Contributing

This Zig backend is part of the Port Kill Monitor project, licensed under the MIT License.

### Contributing to Zig Backend
1. **Setup development environment** with Zig 0.15+
2. **Run tests** to ensure functionality: `zig build test`
3. **Follow Zig style conventions** and memory safety practices
4. **Add tests** for new functionality
5. **Document performance characteristics** of changes

### Code Quality Standards
- **Memory safety**: No memory leaks, proper resource management
- **Error handling**: Comprehensive error coverage with meaningful messages
- **Performance**: Maintain optimal performance characteristics
- **Testing**: Unit tests for all core functionality
- **Documentation**: Clear inline documentation for public APIs

---

This Zig backend provides the high-performance foundation for the Port Kill Monitor application, delivering efficient system monitoring capabilities with minimal resource overhead.
