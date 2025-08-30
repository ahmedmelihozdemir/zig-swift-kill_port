const std = @import("std");
const types = @import("types.zig");
const AppConfig = types.AppConfig;

pub const CliParser = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) CliParser {
        return CliParser{
            .allocator = allocator,
        };
    }

    pub fn parseArgs(self: *CliParser) !AppConfig {
        var config = AppConfig.init(self.allocator);

        // Get command line arguments
        const args = try std.process.argsAlloc(self.allocator);
        defer std.process.argsFree(self.allocator, args);

        var i: usize = 1; // Skip program name
        while (i < args.len) : (i += 1) {
            const arg = args[i];

            if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
                self.printHelp();
                std.process.exit(0);
            } else if (std.mem.eql(u8, arg, "--version") or std.mem.eql(u8, arg, "-V")) {
                self.printVersion();
                std.process.exit(0);
            } else if (std.mem.eql(u8, arg, "--verbose") or std.mem.eql(u8, arg, "-v")) {
                config.verbose = true;
            } else if (std.mem.eql(u8, arg, "--console") or std.mem.eql(u8, arg, "-c")) {
                config.console_mode = true;
            } else if (std.mem.eql(u8, arg, "--start-port") or std.mem.eql(u8, arg, "-s")) {
                i += 1;
                if (i >= args.len) {
                    std.log.err("--start-port requires a value", .{});
                    return error.InvalidArgument;
                }
                config.start_port = std.fmt.parseInt(u16, args[i], 10) catch |err| {
                    std.log.err("Invalid start port: {s} ({})", .{ args[i], err });
                    return error.InvalidArgument;
                };
            } else if (std.mem.eql(u8, arg, "--end-port") or std.mem.eql(u8, arg, "-e")) {
                i += 1;
                if (i >= args.len) {
                    std.log.err("--end-port requires a value", .{});
                    return error.InvalidArgument;
                }
                config.end_port = std.fmt.parseInt(u16, args[i], 10) catch |err| {
                    std.log.err("Invalid end port: {s} ({})", .{ args[i], err });
                    return error.InvalidArgument;
                };
            } else if (std.mem.eql(u8, arg, "--ports") or std.mem.eql(u8, arg, "-p")) {
                i += 1;
                if (i >= args.len) {
                    std.log.err("--ports requires a value", .{});
                    return error.InvalidArgument;
                }

                // Parse comma-separated ports
                const ports_str = args[i];
                var port_list = std.ArrayListUnmanaged(u16){};
                defer port_list.deinit(self.allocator);

                var iter = std.mem.splitScalar(u8, ports_str, ',');
                while (iter.next()) |port_str| {
                    const trimmed = std.mem.trim(u8, port_str, " \t");
                    if (trimmed.len == 0) continue;

                    const port = std.fmt.parseInt(u16, trimmed, 10) catch |err| {
                        std.log.err("Invalid port: {s} ({})", .{ trimmed, err });
                        return error.InvalidArgument;
                    };

                    try port_list.append(self.allocator, port);
                }

                if (port_list.items.len == 0) {
                    std.log.err("No valid ports specified", .{});
                    return error.InvalidArgument;
                }

                config.specific_ports = try self.allocator.dupe(u16, port_list.items);
            } else {
                std.log.err("Unknown argument: {s}", .{arg});
                self.printHelp();
                return error.InvalidArgument;
            }
        }

        try config.validate();
        return config;
    }

    fn printHelp(self: *CliParser) void {
        _ = self;
        std.debug.print(
            \\port-kill 0.1.0
            \\A lightweight macOS status bar app that monitors and manages development processes
            \\
            \\USAGE:
            \\    port-kill [OPTIONS]
            \\
            \\OPTIONS:
            \\    -s, --start-port <PORT>    Starting port for range scanning (inclusive) [default: 2000]
            \\    -e, --end-port <PORT>      Ending port for range scanning (inclusive) [default: 6000]
            \\    -p, --ports <PORTS>        Specific ports to monitor (comma-separated, overrides start/end port range)
            \\    -c, --console              Run in console mode instead of status bar mode
            \\    -v, --verbose              Enable verbose logging
            \\    -h, --help                 Print help information
            \\    -V, --version              Print version information
            \\
            \\EXAMPLES:
            \\    port-kill                           # Default: ports 2000-6000
            \\    port-kill --start-port 3000         # Ports 3000-6000
            \\    port-kill --end-port 8080           # Ports 2000-8080
            \\    port-kill --ports 3000,8000,8080    # Specific ports only
            \\    port-kill --console                 # Run in console mode
            \\    port-kill --verbose                 # Enable verbose logging
            \\
        , .{});
    }

    fn printVersion(self: *CliParser) void {
        _ = self;
        std.debug.print("port-kill 0.1.0\n", .{});
    }
};

test "CliParser basic functionality" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var parser = CliParser.init(allocator);

    // Test default config when no args
    const original_args = std.os.argv;
    defer std.os.argv = original_args;

    const test_args = [_][*:0]u8{
        @ptrCast("port-kill"),
    };
    std.os.argv = @constCast(test_args[0..test_args.len]);

    var config = try parser.parseArgs();
    defer config.deinit();

    try std.testing.expect(config.start_port == 2000);
    try std.testing.expect(config.end_port == 6000);
    try std.testing.expect(config.specific_ports == null);
    try std.testing.expect(!config.console_mode);
    try std.testing.expect(!config.verbose);
}
