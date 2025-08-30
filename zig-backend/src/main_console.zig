const std = @import("std");
const cli = @import("cli.zig");
const console_app = @import("console_app.zig");

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

    // Force console mode for this executable
    config.console_mode = true;

    // Set log level based on verbose flag
    if (config.verbose) {
        std.log.info("Verbose logging enabled", .{});
    }

    const port_desc = try config.getPortDescription(allocator);
    defer allocator.free(port_desc);

    std.log.info("Starting Console Port Kill application...", .{});
    std.log.info("Monitoring: {s}", .{port_desc});

    // Run in console mode
    var app = console_app.ConsoleApp.init(allocator, config) catch |err| {
        std.log.err("Failed to initialize console application: {}", .{err});
        return;
    };
    defer app.deinit();

    try app.run();
}
