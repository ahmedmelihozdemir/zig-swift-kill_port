const std = @import("std");

/// Process information structure with proper resource management
pub const ProcessInfo = struct {
    pid: i32,
    port: u16,
    command: []const u8,
    name: []const u8,

    /// Initialize ProcessInfo with owned strings
    pub fn init(allocator: std.mem.Allocator, pid: i32, port: u16, command: []const u8, name: []const u8) !ProcessInfo {
        return ProcessInfo{
            .pid = pid,
            .port = port,
            .command = try allocator.dupe(u8, command),
            .name = try allocator.dupe(u8, name),
        };
    }

    /// Free allocated memory
    pub fn deinit(self: *ProcessInfo, allocator: std.mem.Allocator) void {
        allocator.free(self.command);
        allocator.free(self.name);
        self.* = undefined; // Prevent use-after-free
    }

    /// Create a deep copy of ProcessInfo
    pub fn clone(self: ProcessInfo, allocator: std.mem.Allocator) !ProcessInfo {
        return ProcessInfo.init(allocator, self.pid, self.port, self.command, self.name);
    }

    /// Check if two ProcessInfo instances are equal
    pub fn eql(self: ProcessInfo, other: ProcessInfo) bool {
        return self.pid == other.pid and
            self.port == other.port and
            std.mem.eql(u8, self.command, other.command) and
            std.mem.eql(u8, self.name, other.name);
    }

    pub fn format(
        value: ProcessInfo,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("ProcessInfo{{ .pid = {}, .port = {}, .name = \"{s}\", .command = \"{s}\" }}", .{ value.pid, value.port, value.name, value.command });
    }
};

/// Process update container with proper resource management
pub const ProcessUpdate = struct {
    processes: std.AutoHashMap(u16, ProcessInfo),
    count: usize,
    allocator: std.mem.Allocator,

    /// Initialize ProcessUpdate with the given allocator
    pub fn init(allocator: std.mem.Allocator) ProcessUpdate {
        return ProcessUpdate{
            .processes = std.AutoHashMap(u16, ProcessInfo).init(allocator),
            .count = 0,
            .allocator = allocator,
        };
    }

    /// Free all resources including ProcessInfo instances
    pub fn deinit(self: *ProcessUpdate) void {
        self.clear();
        self.processes.deinit();
        self.* = undefined; // Prevent use-after-free
    }

    /// Clear all processes and free their memory
    pub fn clear(self: *ProcessUpdate) void {
        var iterator = self.processes.iterator();
        while (iterator.next()) |entry| {
            var process_info = entry.value_ptr;
            process_info.deinit(self.allocator);
        }
        self.processes.clearAndFree();
        self.count = 0;
    }

    /// Add a process to the update, taking ownership of the ProcessInfo
    pub fn addProcess(self: *ProcessUpdate, port: u16, process_info: ProcessInfo) !void {
        try self.processes.put(port, process_info);
        self.updateCount();
    }

    /// Update the count of processes
    pub fn updateCount(self: *ProcessUpdate) void {
        self.count = self.processes.count();
    }

    /// Get process by port (returns null if not found)
    pub fn getProcess(self: *ProcessUpdate, port: u16) ?*ProcessInfo {
        return self.processes.getPtr(port);
    }

    /// Check if a port has a process
    pub fn hasProcess(self: *ProcessUpdate, port: u16) bool {
        return self.processes.contains(port);
    }
};

/// Status bar information with proper memory management
pub const StatusBarInfo = struct {
    text: []const u8,
    tooltip: []const u8,
    allocator: std.mem.Allocator,

    /// Initialize StatusBarInfo with copied strings
    pub fn init(allocator: std.mem.Allocator, text: []const u8, tooltip: []const u8) !StatusBarInfo {
        return StatusBarInfo{
            .text = try allocator.dupe(u8, text),
            .tooltip = try allocator.dupe(u8, tooltip),
            .allocator = allocator,
        };
    }

    /// Free allocated memory
    pub fn deinit(self: *StatusBarInfo) void {
        self.allocator.free(self.text);
        self.allocator.free(self.tooltip);
        self.* = undefined; // Prevent use-after-free
    }

    /// Create StatusBarInfo from process count with optimized memory usage
    pub fn fromProcessCount(allocator: std.mem.Allocator, count: usize) !StatusBarInfo {
        // Pre-allocate with reasonable buffer size to avoid reallocations
        const text = try std.fmt.allocPrint(allocator, "{}", .{count});
        errdefer allocator.free(text);

        const tooltip = if (count == 0)
            try allocator.dupe(u8, "No development processes running")
        else if (count == 1)
            try allocator.dupe(u8, "1 development process running")
        else
            try std.fmt.allocPrint(allocator, "{} development processes running", .{count});
        errdefer allocator.free(tooltip);

        return StatusBarInfo{
            .text = text,
            .tooltip = tooltip,
            .allocator = allocator,
        };
    }
};

/// Application configuration with validation and resource management
pub const AppConfig = struct {
    start_port: u16 = 2000,
    end_port: u16 = 6000,
    specific_ports: ?[]const u16 = null,
    console_mode: bool = false,
    verbose: bool = false,
    allocator: std.mem.Allocator,

    /// Initialize configuration with allocator
    pub fn init(allocator: std.mem.Allocator) AppConfig {
        return AppConfig{
            .allocator = allocator,
        };
    }

    /// Free allocated resources
    pub fn deinit(self: *AppConfig) void {
        if (self.specific_ports) |ports| {
            self.allocator.free(ports);
        }
        self.* = undefined; // Prevent use-after-free
    }

    /// Get list of ports to monitor (caller owns the returned slice)
    pub fn getPortsToMonitor(self: AppConfig, allocator: std.mem.Allocator) ![]u16 {
        if (self.specific_ports) |specific_ports| {
            return try allocator.dupe(u16, specific_ports);
        } else {
            const count = self.end_port - self.start_port + 1;
            const ports = try allocator.alloc(u16, count);
            errdefer allocator.free(ports);

            for (ports, 0..) |*port, i| {
                port.* = self.start_port + @as(u16, @intCast(i));
            }
            return ports;
        }
    }

    /// Get human-readable description of monitored ports (caller owns the returned string)
    pub fn getPortDescription(self: AppConfig, allocator: std.mem.Allocator) ![]const u8 {
        if (self.specific_ports) |specific_ports| {
            // Use ArrayListUnmanaged for better memory management
            var port_strs = std.ArrayListUnmanaged([]const u8){};
            defer {
                for (port_strs.items) |str| {
                    allocator.free(str);
                }
                port_strs.deinit(allocator);
            }

            for (specific_ports) |port| {
                const port_str = try std.fmt.allocPrint(allocator, "{}", .{port});
                try port_strs.append(allocator, port_str);
            }

            const joined = try std.mem.join(allocator, ", ", port_strs.items);
            return try std.fmt.allocPrint(allocator, "specific ports: {s}", .{joined});
        } else {
            return try std.fmt.allocPrint(allocator, "port range: {}-{}", .{ self.start_port, self.end_port });
        }
    }

    /// Validate configuration parameters
    pub fn validate(self: AppConfig) !void {
        if (self.start_port == 0 or self.end_port == 0) {
            return PortKillError.InvalidPort;
        }

        if (self.start_port > self.end_port) {
            return PortKillError.InvalidPortRange;
        }

        if (self.specific_ports) |specific_ports| {
            if (specific_ports.len == 0) {
                return PortKillError.EmptyPortList;
            }

            for (specific_ports) |port| {
                if (port == 0) {
                    return PortKillError.InvalidPort;
                }
            }
        }
    }

    /// Get the total number of ports being monitored
    pub fn getPortCount(self: AppConfig) usize {
        if (self.specific_ports) |specific_ports| {
            return specific_ports.len;
        } else {
            return self.end_port - self.start_port + 1;
        }
    }
};

/// Enhanced error types with more specific error conditions
pub const PortKillError = error{
    // Port-related errors
    InvalidPortRange,
    EmptyPortList,
    InvalidPort,
    PortNotFound,

    // Process-related errors
    ProcessNotFound,
    ProcessAlreadyTerminated,
    KillFailed,
    PermissionDenied,

    // System-related errors
    CommandFailed,
    CommandTimeout,
    SystemResourceExhausted,

    // Memory-related errors
    OutOfMemory,

    // IO-related errors
    PipeError,
    ReadError,
    WriteError,

    // Configuration errors
    InvalidArgument,
    ConfigurationError,
} || std.process.Child.SpawnError || std.process.Child.WaitError;
