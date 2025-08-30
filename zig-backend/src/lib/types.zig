const std = @import("std");

// Process information structure
pub const ProcessInfo = struct {
    pid: i32,
    port: u16,
    command: []const u8,
    name: []const u8,

    pub fn deinit(self: *ProcessInfo, allocator: std.mem.Allocator) void {
        allocator.free(self.command);
        allocator.free(self.name);
    }

    pub fn clone(self: ProcessInfo, allocator: std.mem.Allocator) !ProcessInfo {
        return ProcessInfo{
            .pid = self.pid,
            .port = self.port,
            .command = try allocator.dupe(u8, self.command),
            .name = try allocator.dupe(u8, self.name),
        };
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

// Process update containing a map of processes
pub const ProcessUpdate = struct {
    processes: std.AutoHashMap(u16, ProcessInfo),
    count: usize,

    pub fn init(allocator: std.mem.Allocator) ProcessUpdate {
        return ProcessUpdate{
            .processes = std.AutoHashMap(u16, ProcessInfo).init(allocator),
            .count = 0,
        };
    }

    pub fn deinit(self: *ProcessUpdate) void {
        var iterator = self.processes.iterator();
        while (iterator.next()) |entry| {
            var process_info = entry.value_ptr;
            process_info.deinit(self.processes.allocator);
        }
        self.processes.deinit();
    }

    pub fn clear(self: *ProcessUpdate) void {
        var iterator = self.processes.iterator();
        while (iterator.next()) |entry| {
            var process_info = entry.value_ptr;
            process_info.deinit(self.processes.allocator);
        }
        self.processes.clearAndFree();
        self.count = 0;
    }

    pub fn updateCount(self: *ProcessUpdate) void {
        self.count = self.processes.count();
    }
};

// Status bar information
pub const StatusBarInfo = struct {
    text: []const u8,
    tooltip: []const u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, text: []const u8, tooltip: []const u8) !StatusBarInfo {
        return StatusBarInfo{
            .text = try allocator.dupe(u8, text),
            .tooltip = try allocator.dupe(u8, tooltip),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *StatusBarInfo) void {
        self.allocator.free(self.text);
        self.allocator.free(self.tooltip);
    }

    pub fn fromProcessCount(allocator: std.mem.Allocator, count: usize) !StatusBarInfo {
        const text = try std.fmt.allocPrint(allocator, "{}", .{count});

        const tooltip = if (count == 0)
            try allocator.dupe(u8, "No development processes running")
        else
            try std.fmt.allocPrint(allocator, "{} development process(es) running", .{count});

        return StatusBarInfo{
            .text = text,
            .tooltip = tooltip,
            .allocator = allocator,
        };
    }
};

// Application configuration
pub const AppConfig = struct {
    start_port: u16 = 2000,
    end_port: u16 = 6000,
    specific_ports: ?[]const u16 = null,
    console_mode: bool = false,
    verbose: bool = false,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) AppConfig {
        return AppConfig{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *AppConfig) void {
        if (self.specific_ports) |ports| {
            self.allocator.free(ports);
        }
    }

    pub fn getPortsToMonitor(self: AppConfig, allocator: std.mem.Allocator) ![]u16 {
        if (self.specific_ports) |specific_ports| {
            return allocator.dupe(u16, specific_ports);
        } else {
            const count = self.end_port - self.start_port + 1;
            const ports = try allocator.alloc(u16, count);
            for (ports, 0..) |*port, i| {
                port.* = self.start_port + @as(u16, @intCast(i));
            }
            return ports;
        }
    }

    pub fn getPortDescription(self: AppConfig, allocator: std.mem.Allocator) ![]const u8 {
        if (self.specific_ports) |specific_ports| {
            var port_strs = std.ArrayListUnmanaged([]const u8){};
            defer port_strs.deinit(allocator);

            for (specific_ports) |port| {
                const port_str = try std.fmt.allocPrint(allocator, "{}", .{port});
                try port_strs.append(allocator, port_str);
            }

            const joined = try std.mem.join(allocator, ", ", port_strs.items);
            defer {
                for (port_strs.items) |str| {
                    allocator.free(str);
                }
            }

            return try std.fmt.allocPrint(allocator, "specific ports: {s}", .{joined});
        } else {
            return try std.fmt.allocPrint(allocator, "port range: {}-{}", .{ self.start_port, self.end_port });
        }
    }

    pub fn validate(self: AppConfig) !void {
        if (self.start_port > self.end_port) {
            return error.InvalidPortRange;
        }

        if (self.specific_ports) |specific_ports| {
            if (specific_ports.len == 0) {
                return error.EmptyPortList;
            }

            for (specific_ports) |port| {
                if (port == 0) {
                    return error.InvalidPort;
                }
            }
        }
    }
};

// Errors
pub const PortKillError = error{
    InvalidPortRange,
    EmptyPortList,
    InvalidPort,
    ProcessNotFound,
    KillFailed,
    CommandFailed,
    PermissionDenied,
    OutOfMemory,
};
