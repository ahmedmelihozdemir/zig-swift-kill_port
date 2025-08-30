const std = @import("std");
const ProcessMonitor = @import("../src/lib/process_monitor.zig").ProcessMonitor;

// Simple example that monitors port 3000 and prints any processes found
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("🔍 Port Monitor Example\n", .{});
    std.debug.print("Monitoring port 3000 for 10 seconds...\n\n", .{});

    const ports = [_]u16{3000};
    var monitor = try ProcessMonitor.init(allocator, &ports);
    defer monitor.deinit();

    var iterations: u8 = 0;
    while (iterations < 5) { // Monitor for 5 iterations (10 seconds)
        var processes = try monitor.scanProcesses();
        defer processes.deinit();

        std.debug.print("Scan #{}: ", .{iterations + 1});

        if (processes.count == 0) {
            std.debug.print("No processes found on port 3000\n", .{});
        } else {
            std.debug.print("Found {} process(es):\n", .{processes.count});
            var iterator = processes.processes.iterator();
            while (iterator.next()) |entry| {
                const port = entry.key_ptr.*;
                const process_info = entry.value_ptr.*;
                std.debug.print("  → Port {}: {s} (PID {})\n", .{ port, process_info.name, process_info.pid });
            }
        }

        std.time.sleep(2 * std.time.ns_per_s); // Sleep for 2 seconds
        iterations += 1;
    }

    std.debug.print("\n✅ Example completed!\n", .{});
}
