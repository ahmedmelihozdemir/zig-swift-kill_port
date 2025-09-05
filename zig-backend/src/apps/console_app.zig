const std = @import("std");
const types = @import("../lib/types.zig");
const ProcessMonitor = @import("../lib/process_monitor.zig").ProcessMonitor;
const AppConfig = types.AppConfig;
const StatusBarInfo = types.StatusBarInfo;
const PortKillError = types.PortKillError;

/// Console application with enhanced error handling and user experience
pub const ConsoleApp = struct {
    allocator: std.mem.Allocator,
    config: AppConfig,
    process_monitor: ProcessMonitor,
    is_running: bool,

    /// Initialize console application with configuration
    pub fn init(allocator: std.mem.Allocator, config: AppConfig) !ConsoleApp {
        const ports = config.getPortsToMonitor(allocator) catch |err| {
            std.log.err("Failed to get ports to monitor: {}", .{err});
            return err;
        };
        defer allocator.free(ports);

        const process_monitor = ProcessMonitor.init(allocator, ports) catch |err| {
            std.log.err("Failed to initialize process monitor: {}", .{err});
            return err;
        };

        return ConsoleApp{
            .allocator = allocator,
            .config = config,
            .process_monitor = process_monitor,
            .is_running = false,
        };
    }

    /// Clean up resources
    pub fn deinit(self: *ConsoleApp) void {
        self.process_monitor.deinit();
        self.config.deinit();
        self.* = undefined; // Prevent use-after-free
    }

    /// Run the console application with enhanced monitoring
    pub fn run(self: *ConsoleApp) !void {
        self.is_running = true;
        defer self.is_running = false;

        std.log.info("Starting Kill Port Console Monitor...", .{});

        const port_desc = self.config.getPortDescription(self.allocator) catch |err| {
            std.log.err("Failed to get port description: {}", .{err});
            return err;
        };
        defer self.allocator.free(port_desc);

        // Print startup banner
        self.printStartupBanner(port_desc);

        var last_process_count: usize = std.math.maxInt(usize); // Force initial display
        var consecutive_errors: usize = 0;
        const max_consecutive_errors = 5;

        while (self.is_running) {
            var processes = self.process_monitor.scanProcesses() catch |err| {
                consecutive_errors += 1;
                std.log.err("Failed to scan processes (error {}/{}): {}", .{ consecutive_errors, max_consecutive_errors, err });

                if (consecutive_errors >= max_consecutive_errors) {
                    std.log.err("Too many consecutive errors, exiting", .{});
                    return PortKillError.SystemResourceExhausted;
                }

                std.Thread.sleep(ProcessMonitor.MONITORING_INTERVAL_MS * std.time.ns_per_ms);
                continue;
            };
            defer processes.deinit();

            // Reset error counter on successful scan
            consecutive_errors = 0;

            // Only print status if process count changed or verbose mode
            if (processes.count != last_process_count or self.config.verbose) {
                self.displayProcessStatus(&processes) catch |err| {
                    std.log.err("Failed to display process status: {}", .{err});
                    // Continue running even if display fails
                };
                last_process_count = processes.count;
            }

            std.Thread.sleep(ProcessMonitor.MONITORING_INTERVAL_MS * std.time.ns_per_ms);
        }
    }

    /// Print startup banner with configuration information
    fn printStartupBanner(self: *ConsoleApp, port_desc: []const u8) void {
        std.debug.print("\n🚀 Kill Port Console Monitor Started!\n", .{});
        std.debug.print("📡 Monitoring {s} every {}s...\n", .{ port_desc, ProcessMonitor.MONITORING_INTERVAL_MS / 1000 });
        std.debug.print("💡 Press Ctrl+C to quit\n", .{});
        if (self.config.verbose) {
            std.debug.print("🔍 Verbose logging enabled\n", .{});
        }
        std.debug.print("{s}\n", .{"─" ** 50});
        std.debug.print("\n", .{});
    }

    /// Display current process status with better formatting
    fn displayProcessStatus(self: *ConsoleApp, processes: *types.ProcessUpdate) !void {
        var status_info = StatusBarInfo.fromProcessCount(self.allocator, processes.count) catch |err| {
            std.log.err("Failed to create status info: {}", .{err});
            return err;
        };
        defer status_info.deinit();

        // Get current timestamp
        const timestamp = std.time.timestamp();

        // Print status with timestamp
        std.debug.print("🔄 [{d}] Port Status: {s} - {s}\n", .{ timestamp, status_info.text, status_info.tooltip });

        if (processes.count > 0) {
            std.debug.print("📋 Detected Processes:\n", .{});
            var iterator = processes.processes.iterator();
            var count: usize = 0;

            while (iterator.next()) |entry| {
                count += 1;
                const port = entry.key_ptr.*;
                const process_info = entry.value_ptr.*;

                std.debug.print("   {}. Port {d}: {s} (PID {d}) - {s}\n", .{ count, port, process_info.name, process_info.pid, process_info.command });
            }
            std.debug.print("\n", .{});
        } else if (self.config.verbose) {
            std.debug.print("✅ No processes found on monitored ports\n\n", .{});
        }
    }

    /// Stop the console application gracefully
    pub fn stop(self: *ConsoleApp) void {
        std.log.info("Stopping console application...", .{});
        self.is_running = false;
    }
};
