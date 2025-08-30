const std = @import("std");
const types = @import("types.zig");
const ProcessMonitor = @import("process_monitor.zig").ProcessMonitor;
const AppConfig = types.AppConfig;
const StatusBarInfo = types.StatusBarInfo;

pub const ConsoleApp = struct {
    allocator: std.mem.Allocator,
    config: AppConfig,
    process_monitor: ProcessMonitor,

    pub fn init(allocator: std.mem.Allocator, config: AppConfig) !ConsoleApp {
        const ports = try config.getPortsToMonitor(allocator);
        defer allocator.free(ports);

        const process_monitor = try ProcessMonitor.init(allocator, ports);

        return ConsoleApp{
            .allocator = allocator,
            .config = config,
            .process_monitor = process_monitor,
        };
    }

    pub fn deinit(self: *ConsoleApp) void {
        self.process_monitor.deinit();
        self.config.deinit();
    }

    pub fn run(self: *ConsoleApp) !void {
        std.log.info("Starting Console Port Kill application...", .{});

        const port_desc = try self.config.getPortDescription(self.allocator);
        defer self.allocator.free(port_desc);

        std.debug.print("🚀 Port Kill Console Monitor Started!\n", .{});
        std.debug.print("📡 Monitoring {s} every 2 seconds...\n", .{port_desc});
        std.debug.print("💡 Press Ctrl+C to quit\n", .{});
        std.debug.print("\n", .{});

        var last_process_count: usize = std.math.maxInt(usize); // Force initial display

        while (true) {
            var processes = self.process_monitor.scanProcesses() catch |err| {
                std.log.err("Failed to scan processes: {}", .{err});
                std.Thread.sleep(ProcessMonitor.MONITORING_INTERVAL_MS * std.time.ns_per_ms);
                continue;
            };
            defer processes.deinit();

            // Only print status if process count changed
            if (processes.count != last_process_count) {
                var status_info = StatusBarInfo.fromProcessCount(self.allocator, processes.count) catch |err| {
                    std.log.err("Failed to create status info: {}", .{err});
                    std.Thread.sleep(ProcessMonitor.MONITORING_INTERVAL_MS * std.time.ns_per_ms);
                    continue;
                };
                defer status_info.deinit();

                // Print status to console
                std.debug.print("🔄 Port Status: {s} - {s}\n", .{ status_info.text, status_info.tooltip });

                if (processes.count > 0) {
                    std.debug.print("📋 Detected Processes:\n", .{});
                    var iterator = processes.processes.iterator();
                    while (iterator.next()) |entry| {
                        const port = entry.key_ptr.*;
                        const process_info = entry.value_ptr.*;
                        std.debug.print("   • Port {}: {s} (PID {}) - {s}\n", .{ port, process_info.name, process_info.pid, process_info.command });
                    }
                    std.debug.print("\n", .{});
                }

                last_process_count = processes.count;
            }

            std.Thread.sleep(ProcessMonitor.MONITORING_INTERVAL_MS * std.time.ns_per_ms);
        }
    }
};
