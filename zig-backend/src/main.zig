const std = @import("std");
const cli = @import("lib/cli.zig");
const console_app = @import("apps/console_app.zig");
const TrayApp = @import("apps/tray_app.zig").TrayApp;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Parse command line arguments
    var parser = cli.CliParser.init(allocator);
    var config = parser.parseArgs() catch |err| {
        std.log.err("Failed to parse arguments: {}", .{err});
        std.process.exit(1);
    };
    defer config.deinit();

    // Set log level based on verbose flag
    if (config.verbose) {
        // In Zig 0.15.1, we can use the built-in logging
        std.log.info("Verbose logging enabled", .{});
    }

    const port_desc = try config.getPortDescription(allocator);
    defer allocator.free(port_desc);

    std.log.info("Starting Port Kill application...", .{});
    std.log.info("Monitoring: {s}", .{port_desc});

    if (config.console_mode) {
        // Run in console mode
        var app = console_app.ConsoleApp.init(allocator, config) catch |err| {
            std.log.err("Failed to initialize console application: {}", .{err});
            return;
        };
        defer app.deinit();

        try app.run();
    } else {
        // Run in tray mode
        var app = TrayApp.init(allocator, config) catch |err| {
            std.log.err("Failed to initialize tray application: {}", .{err});
            return;
        };
        defer app.deinit();

        try app.run();
    }
}
