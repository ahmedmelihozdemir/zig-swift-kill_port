const std = @import("std");
const types = @import("types.zig");
const AppConfig = types.AppConfig;
const PortKillError = types.PortKillError;

/// Command line interface parser with enhanced error handling
pub const CliParser = struct {
    allocator: std.mem.Allocator,

    /// Initialize CLI parser with allocator
    pub fn init(allocator: std.mem.Allocator) CliParser {
        return CliParser{
            .allocator = allocator,
        };
    }

    /// Parse command line arguments with comprehensive error handling
    pub fn parseArgs(self: *CliParser) !AppConfig {
        var config = AppConfig.init(self.allocator);
        errdefer config.deinit();

        // Get command line arguments
        const args = std.process.argsAlloc(self.allocator) catch |err| {
            std.log.err("Failed to allocate memory for arguments: {}", .{err});
            return PortKillError.OutOfMemory;
        };
        defer std.process.argsFree(self.allocator, args);

        if (args.len == 0) {
            std.log.err("No arguments provided", .{});
            return PortKillError.InvalidArgument;
        }

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
                    return PortKillError.InvalidArgument;
                }
                config.start_port = std.fmt.parseInt(u16, args[i], 10) catch |err| {
                    std.log.err("Invalid start port: {s} ({})", .{ args[i], err });
                    return PortKillError.InvalidArgument;
                };
                if (config.start_port == 0) {
                    std.log.err("Start port cannot be 0", .{});
                    return PortKillError.InvalidPort;
                }
            } else if (std.mem.eql(u8, arg, "--end-port") or std.mem.eql(u8, arg, "-e")) {
                i += 1;
                if (i >= args.len) {
                    std.log.err("--end-port requires a value", .{});
                    return PortKillError.InvalidArgument;
                }
                config.end_port = std.fmt.parseInt(u16, args[i], 10) catch |err| {
                    std.log.err("Invalid end port: {s} ({})", .{ args[i], err });
                    return PortKillError.InvalidArgument;
                };
                if (config.end_port == 0) {
                    std.log.err("End port cannot be 0", .{});
                    return PortKillError.InvalidPort;
                }
            } else if (std.mem.eql(u8, arg, "--ports") or std.mem.eql(u8, arg, "-p")) {
                try self.parsePortsList(&config, args, &i);
            } else {
                std.log.err("Unknown argument: {s}", .{arg});
                self.printHelp();
                return PortKillError.InvalidArgument;
            }
        }

        try config.validate();
        return config;
    }

    /// Parse comma-separated ports list with validation
    fn parsePortsList(self: *CliParser, config: *AppConfig, args: [][:0]u8, i: *usize) !void {
        i.* += 1;
        if (i.* >= args.len) {
            std.log.err("--ports requires a value", .{});
            return PortKillError.InvalidArgument;
        }

        // Parse comma-separated ports
        const ports_str = args[i.*];
        var port_list = std.ArrayListUnmanaged(u16){};
        defer port_list.deinit(self.allocator);

        var iter = std.mem.splitScalar(u8, ports_str, ',');
        while (iter.next()) |port_str| {
            const trimmed = std.mem.trim(u8, port_str, " \t");
            if (trimmed.len == 0) continue;

            const port = std.fmt.parseInt(u16, trimmed, 10) catch |err| {
                std.log.err("Invalid port: {s} ({})", .{ trimmed, err });
                return PortKillError.InvalidArgument;
            };

            if (port == 0) {
                std.log.err("Port cannot be 0: {s}", .{trimmed});
                return PortKillError.InvalidPort;
            }

            // Check for duplicates
            for (port_list.items) |existing_port| {
                if (existing_port == port) {
                    std.log.warn("Duplicate port ignored: {}", .{port});
                    continue;
                }
            }

            try port_list.append(self.allocator, port);
        }

        if (port_list.items.len == 0) {
            std.log.err("No valid ports specified", .{});
            return PortKillError.InvalidArgument;
        }

        config.specific_ports = try self.allocator.dupe(u16, port_list.items);
    }

    /// Print help information to stdout
    fn printHelp(self: *CliParser) void {
        _ = self;
        std.debug.print(
            \\kill-port 0.1.0
            \\A lightweight macOS status bar app that monitors and manages development processes
            \\
            \\USAGE:
            \\    kill-port [OPTIONS]
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
            \\    kill-port                           # Default: ports 2000-6000
            \\    kill-port --start-port 3000         # Ports 3000-6000
            \\    kill-port --end-port 8080           # Ports 2000-8080
            \\    kill-port --ports 3000,8000,8080    # Specific ports only
            \\    kill-port --console                 # Run in console mode
            \\    kill-port --verbose                 # Enable verbose logging
            \\
        , .{});
    }

    /// Print version information to stdout
    fn printVersion(self: *CliParser) void {
        _ = self;
        std.debug.print("kill-port 0.1.0\n", .{});
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
        @ptrCast(@constCast("kill-port")),
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
