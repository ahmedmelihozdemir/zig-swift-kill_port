const std = @import("std");
const cli = @import("lib/cli.zig");
const console_app = @import("apps/console_app.zig");
const TrayApp = @import("apps/tray_app.zig").TrayApp;
const types = @import("lib/types.zig");

/// Setup signal handlers for graceful shutdown
fn setupSignalHandlers() void {
    // Note: For production use, consider implementing proper signal handling
    // This is a placeholder for future implementation
    _ = {}; // Suppress unused function warning
}

/// Run application in console mode with proper error handling
fn runConsoleMode(allocator: std.mem.Allocator, config: types.AppConfig) !void {
    var app = console_app.ConsoleApp.init(allocator, config) catch |err| {
        std.log.err("Failed to initialize console application: {}", .{err});
        return err;
    };
    defer app.deinit();

    std.log.info("Starting console mode application", .{});
    try app.run();
}

/// Run application in tray mode with proper error handling
fn runTrayMode(allocator: std.mem.Allocator, config: types.AppConfig) !void {
    var app = TrayApp.init(allocator, config) catch |err| {
        std.log.err("Failed to initialize tray application: {}", .{err});
        return err;
    };
    defer app.deinit();

    std.log.info("Starting tray mode application", .{});
    try app.run();
}

/// Application entry point with enhanced error handling and resource management
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .safety = true,
        .never_unmap = false,
        .retain_metadata = false,
    }){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            std.log.err("Memory leak detected!", .{});
        }
    }
    const allocator = gpa.allocator();

    // Set up signal handlers for graceful shutdown
    setupSignalHandlers();

    // Parse command line arguments with error handling
    var parser = cli.CliParser.init(allocator);
    var config = parser.parseArgs() catch |err| {
        switch (err) {
            types.PortKillError.InvalidArgument => {
                std.log.err("Invalid command line arguments provided", .{});
                std.process.exit(1);
            },
            else => {
                std.log.err("Failed to parse arguments: {}", .{err});
                std.process.exit(1);
            },
        }
    };
    defer config.deinit();

    // Validate configuration
    config.validate() catch |err| {
        std.log.err("Invalid configuration: {}", .{err});
        std.process.exit(1);
    };

    // Set log level based on verbose flag
    if (config.verbose) {
        std.log.info("Verbose logging enabled", .{});
        std.log.info("Monitoring {} ports", .{config.getPortCount()});
    }

    const port_desc = config.getPortDescription(allocator) catch |err| {
        std.log.err("Failed to generate port description: {}", .{err});
        std.process.exit(1);
    };
    defer allocator.free(port_desc);

    std.log.info("Starting Kill Port application...", .{});
    std.log.info("Monitoring: {s}", .{port_desc});

    if (config.console_mode) {
        runConsoleMode(allocator, config) catch |err| {
            std.log.err("Console application failed: {}", .{err});
            std.process.exit(1);
        };
    } else {
        runTrayMode(allocator, config) catch |err| {
            std.log.err("Tray application failed: {}", .{err});
            std.process.exit(1);
        };
    }
}
