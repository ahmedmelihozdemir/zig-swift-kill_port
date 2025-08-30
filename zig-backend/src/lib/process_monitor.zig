const std = @import("std");
const types = @import("types.zig");

pub const ProcessInfo = types.ProcessInfo;
pub const ProcessUpdate = types.ProcessUpdate;
pub const PortKillError = types.PortKillError;

pub const ProcessMonitor = struct {
    allocator: std.mem.Allocator,
    ports_to_monitor: []u16,

    pub const MONITORING_INTERVAL_MS = 2000; // 2 seconds

    pub fn init(allocator: std.mem.Allocator, ports: []const u16) !ProcessMonitor {
        const ports_copy = try allocator.dupe(u16, ports);
        return ProcessMonitor{
            .allocator = allocator,
            .ports_to_monitor = ports_copy,
        };
    }

    pub fn deinit(self: *ProcessMonitor) void {
        self.allocator.free(self.ports_to_monitor);
    }

    pub fn scanProcesses(self: *ProcessMonitor) !ProcessUpdate {
        var processes = ProcessUpdate.init(self.allocator);

        for (self.ports_to_monitor) |port| {
            if (self.getProcessOnPort(port)) |process_info| {
                try processes.processes.put(port, process_info);
            } else |_| {
                // No process on this port, continue
                continue;
            }
        }

        processes.updateCount();
        return processes;
    }

    fn getProcessOnPort(self: *ProcessMonitor, port: u16) !ProcessInfo {
        // Create lsof command to find processes listening on the port
        const port_str = try std.fmt.allocPrint(self.allocator, ":{}", .{port});
        defer self.allocator.free(port_str);

        const args = [_][]const u8{ "lsof", "-ti", port_str, "-sTCP:LISTEN" };

        var child = std.process.Child.init(&args, self.allocator);
        child.stdout_behavior = .Pipe;
        child.stderr_behavior = .Pipe;

        try child.spawn();

        const stdout = try child.stdout.?.readToEndAlloc(self.allocator, 1024);
        defer self.allocator.free(stdout);

        const stderr = try child.stderr.?.readToEndAlloc(self.allocator, 1024);
        defer self.allocator.free(stderr);

        const term = try child.wait();

        switch (term) {
            .Exited => |code| {
                if (code != 0) {
                    return PortKillError.ProcessNotFound;
                }
            },
            else => return PortKillError.CommandFailed,
        }

        const pid_str = std.mem.trim(u8, stdout, " \t\n\r");
        if (pid_str.len == 0) {
            return PortKillError.ProcessNotFound;
        }

        const pid = std.fmt.parseInt(i32, pid_str, 10) catch |err| {
            std.log.err("Failed to parse PID '{s}': {}", .{ pid_str, err });
            return PortKillError.CommandFailed;
        };

        return self.getProcessDetails(pid, port);
    }

    fn getProcessDetails(self: *ProcessMonitor, pid: i32, port: u16) !ProcessInfo {
        const pid_str = try std.fmt.allocPrint(self.allocator, "{}", .{pid});
        defer self.allocator.free(pid_str);

        const args = [_][]const u8{ "ps", "-p", pid_str, "-o", "comm=" };

        var child = std.process.Child.init(&args, self.allocator);
        child.stdout_behavior = .Pipe;
        child.stderr_behavior = .Pipe;

        try child.spawn();

        const stdout = try child.stdout.?.readToEndAlloc(self.allocator, 1024);
        defer self.allocator.free(stdout);

        const stderr = try child.stderr.?.readToEndAlloc(self.allocator, 1024);
        defer self.allocator.free(stderr);

        const term = try child.wait();

        const command = switch (term) {
            .Exited => |code| blk: {
                if (code == 0) {
                    const trimmed = std.mem.trim(u8, stdout, " \t\n\r");
                    if (trimmed.len > 0) {
                        break :blk try self.allocator.dupe(u8, trimmed);
                    } else {
                        break :blk try self.allocator.dupe(u8, "unknown");
                    }
                } else {
                    break :blk try self.allocator.dupe(u8, "unknown");
                }
            },
            else => try self.allocator.dupe(u8, "unknown"),
        };

        // Extract process name (basename of command)
        const name = if (std.mem.lastIndexOf(u8, command, "/")) |last_slash_idx| blk: {
            break :blk try self.allocator.dupe(u8, command[last_slash_idx + 1 ..]);
        } else blk: {
            break :blk try self.allocator.dupe(u8, command);
        };

        return ProcessInfo{
            .pid = pid,
            .port = port,
            .command = command,
            .name = name,
        };
    }

    pub fn killProcess(self: *ProcessMonitor, pid: i32) !void {
        std.log.info("Attempting to kill process {}", .{pid});

        // First try SIGTERM (15)
        if (self.sendSignal(pid, 15)) {
            std.log.info("Sent SIGTERM to process {}", .{pid});

            // Wait 500ms and check if process is still alive
            std.Thread.sleep(500 * std.time.ns_per_ms);

            if (self.isProcessRunning(pid)) {
                std.log.warn("Process {} still running after SIGTERM, sending SIGKILL", .{pid});

                // Send SIGKILL (9) if process is still alive
                if (self.sendSignal(pid, 9)) {
                    std.log.info("Sent SIGKILL to process {}", .{pid});
                } else |err| {
                    std.log.err("Failed to send SIGKILL to process {}: {}", .{ pid, err });
                    return PortKillError.KillFailed;
                }
            } else {
                std.log.info("Process {} terminated successfully with SIGTERM", .{pid});
            }
        } else |err| {
            std.log.err("Failed to send SIGTERM to process {}: {}", .{ pid, err });
            return PortKillError.KillFailed;
        }
    }

    fn sendSignal(self: *ProcessMonitor, pid: i32, signal: i32) !void {
        const pid_str = try std.fmt.allocPrint(self.allocator, "{}", .{pid});
        defer self.allocator.free(pid_str);

        const signal_str = try std.fmt.allocPrint(self.allocator, "-{}", .{signal});
        defer self.allocator.free(signal_str);

        const args = [_][]const u8{ "kill", signal_str, pid_str };

        var child = std.process.Child.init(&args, self.allocator);
        child.stdout_behavior = .Ignore;
        child.stderr_behavior = .Pipe;

        try child.spawn();

        const stderr = try child.stderr.?.readToEndAlloc(self.allocator, 1024);
        defer self.allocator.free(stderr);

        const term = try child.wait();

        switch (term) {
            .Exited => |code| {
                if (code != 0) {
                    if (stderr.len > 0) {
                        std.log.err("Kill command failed: {s}", .{stderr});
                    }
                    return PortKillError.KillFailed;
                }
            },
            else => return PortKillError.CommandFailed,
        }
    }

    fn isProcessRunning(self: *ProcessMonitor, pid: i32) bool {
        const pid_str = std.fmt.allocPrint(self.allocator, "{}", .{pid}) catch return false;
        defer self.allocator.free(pid_str);

        const args = [_][]const u8{ "ps", "-p", pid_str };

        var child = std.process.Child.init(&args, self.allocator);
        child.stdout_behavior = .Ignore;
        child.stderr_behavior = .Ignore;

        child.spawn() catch return false;

        const term = child.wait() catch return false;

        return switch (term) {
            .Exited => |code| code == 0,
            else => false,
        };
    }

    pub fn killAllProcesses(self: *ProcessMonitor) !void {
        std.log.info("Killing all monitored processes", .{});

        var processes = self.scanProcesses() catch |err| {
            std.log.err("Failed to scan processes: {}", .{err});
            return PortKillError.CommandFailed;
        };
        defer processes.deinit();

        var error_count: usize = 0;
        var iterator = processes.processes.iterator();

        while (iterator.next()) |entry| {
            const port = entry.key_ptr.*;
            const process_info = entry.value_ptr.*;

            std.log.info("Killing process on port {} (PID: {})", .{ port, process_info.pid });

            if (self.killProcess(process_info.pid)) {
                // Success
            } else |err| {
                std.log.err("Failed to kill process on port {} (PID {}): {}", .{ port, process_info.pid, err });
                error_count += 1;
            }
        }

        if (error_count > 0) {
            std.log.err("Failed to kill {} processes", .{error_count});
            return PortKillError.KillFailed;
        }

        std.log.info("All processes killed successfully", .{});
    }
};

test "ProcessMonitor basic functionality" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const ports = [_]u16{ 3000, 3001, 8000 };
    var monitor = try ProcessMonitor.init(allocator, &ports);
    defer monitor.deinit();

    // This will likely find no processes unless you have something running
    var processes = try monitor.scanProcesses();
    defer processes.deinit();

    std.log.info("Found {} processes", .{processes.count});
}
