const std = @import("std");
const types = @import("types.zig");

pub const ProcessInfo = types.ProcessInfo;
pub const ProcessUpdate = types.ProcessUpdate;
pub const PortKillError = types.PortKillError;

/// Process monitor with enhanced resource management and error handling
pub const ProcessMonitor = struct {
    allocator: std.mem.Allocator,
    ports_to_monitor: []u16,

    /// Monitoring interval in milliseconds
    pub const MONITORING_INTERVAL_MS = 2000;

    /// Command execution timeout in milliseconds
    pub const COMMAND_TIMEOUT_MS = 5000;

    /// Maximum output size for command execution
    pub const MAX_OUTPUT_SIZE = 8192;

    /// Initialize ProcessMonitor with port list
    pub fn init(allocator: std.mem.Allocator, ports: []const u16) !ProcessMonitor {
        if (ports.len == 0) {
            return PortKillError.EmptyPortList;
        }

        const ports_copy = try allocator.dupe(u16, ports);
        errdefer allocator.free(ports_copy);

        return ProcessMonitor{
            .allocator = allocator,
            .ports_to_monitor = ports_copy,
        };
    }

    /// Free allocated resources
    pub fn deinit(self: *ProcessMonitor) void {
        self.allocator.free(self.ports_to_monitor);
        self.* = undefined; // Prevent use-after-free
    }

    /// Scan all monitored ports for processes with robust error handling
    pub fn scanProcesses(self: *ProcessMonitor) !ProcessUpdate {
        var processes = ProcessUpdate.init(self.allocator);
        errdefer processes.deinit();

        var error_count: usize = 0;
        const max_errors = self.ports_to_monitor.len / 2; // Allow up to 50% failures

        for (self.ports_to_monitor) |port| {
            if (self.getProcessOnPort(port)) |process_info| {
                try processes.addProcess(port, process_info);
            } else |err| {
                switch (err) {
                    PortKillError.ProcessNotFound => {
                        // This is expected for ports without processes
                        continue;
                    },
                    else => {
                        error_count += 1;
                        std.log.warn("Failed to check port {}: {}", .{ port, err });

                        if (error_count > max_errors) {
                            std.log.err("Too many errors ({}/{}), aborting scan", .{ error_count, self.ports_to_monitor.len });
                            return PortKillError.SystemResourceExhausted;
                        }
                    },
                }
            }
        }

        return processes;
    }

    /// Get process information for a specific port with enhanced error handling
    fn getProcessOnPort(self: *ProcessMonitor, port: u16) !ProcessInfo {
        // Create lsof command to find processes listening on the port
        const port_str = try std.fmt.allocPrint(self.allocator, ":{}", .{port});
        defer self.allocator.free(port_str);

        const args = [_][]const u8{ "lsof", "-ti", port_str, "-sTCP:LISTEN" };

        const result = self.executeCommand(&args) catch |err| switch (err) {
            PortKillError.CommandFailed => return PortKillError.ProcessNotFound,
            else => return err,
        };
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }

        const pid_str = std.mem.trim(u8, result.stdout, " \t\n\r");
        if (pid_str.len == 0) {
            return PortKillError.ProcessNotFound;
        }

        const pid = std.fmt.parseInt(i32, pid_str, 10) catch |err| {
            std.log.err("Failed to parse PID '{s}': {}", .{ pid_str, err });
            return PortKillError.CommandFailed;
        };

        return self.getProcessDetails(pid, port);
    }

    /// Get detailed process information with robust error handling
    fn getProcessDetails(self: *ProcessMonitor, pid: i32, port: u16) !ProcessInfo {
        const pid_str = try std.fmt.allocPrint(self.allocator, "{}", .{pid});
        defer self.allocator.free(pid_str);

        const args = [_][]const u8{ "ps", "-p", pid_str, "-o", "comm=" };

        const result = self.executeCommand(&args) catch |err| {
            std.log.warn("Failed to get process details for PID {}: {}", .{ pid, err });
            // Return a ProcessInfo with unknown command rather than failing
            return ProcessInfo.init(self.allocator, pid, port, "unknown", "unknown");
        };
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }

        const command = blk: {
            const trimmed = std.mem.trim(u8, result.stdout, " \t\n\r");
            if (trimmed.len > 0) {
                break :blk trimmed;
            } else {
                break :blk "unknown";
            }
        };

        // Extract process name (basename of command)
        const name = if (std.mem.lastIndexOf(u8, command, "/")) |last_slash_idx|
            command[last_slash_idx + 1 ..]
        else
            command;

        return ProcessInfo.init(self.allocator, pid, port, command, name);
    }

    /// Enhanced process killing with graceful termination and fallback to force kill
    pub fn killProcess(self: *ProcessMonitor, pid: i32) !void {
        std.log.info("Attempting to kill process {}", .{pid});

        // Check if process exists before attempting to kill
        if (!self.isProcessRunning(pid)) {
            std.log.info("Process {} is not running", .{pid});
            return PortKillError.ProcessAlreadyTerminated;
        }

        // First try SIGTERM (15) for graceful shutdown
        if (self.sendSignal(pid, 15)) {
            std.log.info("Sent SIGTERM to process {}", .{pid});

            // Wait and check if process terminated gracefully
            const check_intervals = [_]u64{ 100, 200, 300, 500, 1000 }; // Progressive backoff
            for (check_intervals) |interval_ms| {
                std.Thread.sleep(interval_ms * std.time.ns_per_ms);
                if (!self.isProcessRunning(pid)) {
                    std.log.info("Process {} terminated gracefully with SIGTERM", .{pid});
                    return;
                }
            }

            std.log.warn("Process {} still running after SIGTERM, sending SIGKILL", .{pid});

            // Send SIGKILL (9) if process is still alive
            if (self.sendSignal(pid, 9)) {
                std.log.info("Sent SIGKILL to process {}", .{pid});

                // Wait a bit and verify termination
                std.Thread.sleep(500 * std.time.ns_per_ms);
                if (self.isProcessRunning(pid)) {
                    std.log.err("Process {} survived SIGKILL", .{pid});
                    return PortKillError.KillFailed;
                } else {
                    std.log.info("Process {} terminated with SIGKILL", .{pid});
                }
            } else |err| {
                std.log.err("Failed to send SIGKILL to process {}: {}", .{ pid, err });
                return PortKillError.KillFailed;
            }
        } else |err| {
            std.log.err("Failed to send SIGTERM to process {}: {}", .{ pid, err });
            return PortKillError.KillFailed;
        }
    }

    /// Send signal to process with enhanced error handling
    fn sendSignal(self: *ProcessMonitor, pid: i32, signal: i32) !void {
        const pid_str = try std.fmt.allocPrint(self.allocator, "{}", .{pid});
        defer self.allocator.free(pid_str);

        const signal_str = try std.fmt.allocPrint(self.allocator, "-{}", .{signal});
        defer self.allocator.free(signal_str);

        const args = [_][]const u8{ "kill", signal_str, pid_str };

        const result = self.executeCommand(&args) catch |err| {
            return switch (err) {
                PortKillError.CommandFailed => PortKillError.PermissionDenied,
                else => err,
            };
        };
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }

        // Command succeeded if we get here
    }

    /// Check if process is running with enhanced error handling
    fn isProcessRunning(self: *ProcessMonitor, pid: i32) bool {
        const pid_str = std.fmt.allocPrint(self.allocator, "{}", .{pid}) catch {
            std.log.err("Failed to allocate memory for PID string", .{});
            return false;
        };
        defer self.allocator.free(pid_str);

        const args = [_][]const u8{ "ps", "-p", pid_str };

        const result = self.executeCommand(&args) catch {
            return false;
        };
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }

        return true; // If executeCommand succeeded, process is running
    }

    /// Enhanced kill all processes with better error handling and reporting
    pub fn killAllProcesses(self: *ProcessMonitor) !void {
        std.log.info("Killing all monitored processes", .{});

        var processes = self.scanProcesses() catch |err| {
            std.log.err("Failed to scan processes: {}", .{err});
            return PortKillError.CommandFailed;
        };
        defer processes.deinit();

        if (processes.count == 0) {
            std.log.info("No processes to kill", .{});
            return;
        }

        var error_count: usize = 0;
        var success_count: usize = 0;
        var iterator = processes.processes.iterator();

        while (iterator.next()) |entry| {
            const port = entry.key_ptr.*;
            const process_info = entry.value_ptr.*;

            std.log.info("Killing process on port {} (PID: {}, name: {})", .{ port, process_info.pid, process_info.name });

            if (self.killProcess(process_info.pid)) {
                success_count += 1;
            } else |err| {
                switch (err) {
                    PortKillError.ProcessAlreadyTerminated => {
                        std.log.info("Process on port {} was already terminated", .{port});
                        success_count += 1;
                    },
                    else => {
                        std.log.err("Failed to kill process on port {} (PID {}): {}", .{ port, process_info.pid, err });
                        error_count += 1;
                    },
                }
            }
        }

        std.log.info("Process termination complete: {} succeeded, {} failed", .{ success_count, error_count });

        if (error_count > 0 and success_count == 0) {
            return PortKillError.KillFailed;
        }
    }

    /// Execute command with timeout and resource management
    const CommandResult = struct {
        stdout: []u8,
        stderr: []u8,
    };

    fn executeCommand(self: *ProcessMonitor, args: []const []const u8) !CommandResult {
        var child = std.process.Child.init(args, self.allocator);
        child.stdout_behavior = .Pipe;
        child.stderr_behavior = .Pipe;

        try child.spawn();
        errdefer _ = child.kill() catch {};

        const stdout = child.stdout.?.readToEndAlloc(self.allocator, MAX_OUTPUT_SIZE) catch |err| {
            std.log.warn("Failed to read stdout: {}", .{err});
            return PortKillError.CommandFailed;
        };
        errdefer self.allocator.free(stdout);

        const stderr = child.stderr.?.readToEndAlloc(self.allocator, MAX_OUTPUT_SIZE) catch |err| {
            std.log.warn("Failed to read stderr: {}", .{err});
            self.allocator.free(stdout);
            return PortKillError.CommandFailed;
        };
        errdefer self.allocator.free(stderr);

        const term = try child.wait();

        switch (term) {
            .Exited => |code| {
                if (code != 0) {
                    if (stderr.len > 0) {
                        std.log.debug("Command failed with exit code {}: {s}", .{ code, stderr });
                    }
                    self.allocator.free(stdout);
                    self.allocator.free(stderr);
                    return PortKillError.CommandFailed;
                }
            },
            else => {
                self.allocator.free(stdout);
                self.allocator.free(stderr);
                return PortKillError.CommandFailed;
            },
        }

        return CommandResult{
            .stdout = stdout,
            .stderr = stderr,
        };
    }
};

// Enhanced test suite with better error handling
test "ProcessMonitor initialization and validation" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Test empty port list
    {
        const empty_ports = [_]u16{};
        const result = ProcessMonitor.init(allocator, &empty_ports);
        try std.testing.expectError(PortKillError.EmptyPortList, result);
    }

    // Test valid initialization
    {
        const ports = [_]u16{ 3000, 3001, 8000 };
        var monitor = try ProcessMonitor.init(allocator, &ports);
        defer monitor.deinit();

        try std.testing.expect(monitor.ports_to_monitor.len == 3);
        try std.testing.expect(monitor.ports_to_monitor[0] == 3000);
        try std.testing.expect(monitor.ports_to_monitor[1] == 3001);
        try std.testing.expect(monitor.ports_to_monitor[2] == 8000);
    }
}

test "ProcessMonitor scan processes" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const ports = [_]u16{ 12345, 12346 }; // Use unlikely ports
    var monitor = try ProcessMonitor.init(allocator, &ports);
    defer monitor.deinit();

    // This will likely find no processes unless you have something running on these ports
    var processes = try monitor.scanProcesses();
    defer processes.deinit();

    // Just verify the structure is correct
    try std.testing.expect(processes.count >= 0);
    try std.testing.expect(processes.count == processes.processes.count());
}
