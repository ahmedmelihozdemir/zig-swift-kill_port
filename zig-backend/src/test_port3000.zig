const std = @import("std");
const ProcessMonitor = @import("lib/process_monitor.zig").ProcessMonitor;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Port 3000'i test et
    const ports = [_]u16{3000};
    var monitor = try ProcessMonitor.init(allocator, &ports);
    defer monitor.deinit();

    std.debug.print("🔍 Port 3000 test ediliyor...\n\n", .{});

    // İlk port taraması
    var processes = try monitor.scanProcesses();
    defer processes.deinit();

    if (processes.count == 0) {
        std.debug.print("❌ Port 3000'de aktif process bulunamadı.\n", .{});
        return;
    }

    std.debug.print("✅ Port 3000'de {} process bulundu:\n", .{processes.count});

    var iterator = processes.processes.iterator();
    while (iterator.next()) |entry| {
        const port = entry.key_ptr.*;
        const process_info = entry.value_ptr.*;
        std.debug.print("   🎯 Port {}: {s} (PID {}) - {s}\n", .{ port, process_info.name, process_info.pid, process_info.command });

        if (port == 3000) {
            std.debug.print("\n🔥 Port 3000'deki process'i sonlandırılıyor...\n", .{});

            // Process'i kill et
            monitor.killProcess(process_info.pid) catch |err| {
                std.debug.print("❌ Process sonlandırılamadı: {}\n", .{err});
                return;
            };

            std.debug.print("✅ Process başarıyla sonlandırıldı!\n", .{});

            // Doğrulama - tekrar tarama yap
            std.debug.print("\n🔄 Doğrulama için yeniden taranıyor...\n", .{});
            std.Thread.sleep(1000 * std.time.ns_per_ms); // 1 saniye bekle

            var after_processes = try monitor.scanProcesses();
            defer after_processes.deinit();

            if (after_processes.count == 0) {
                std.debug.print("✅ Port 3000 artık temiz - process başarıyla sonlandırıldı!\n", .{});
            } else {
                std.debug.print("⚠️  Port 3000'de hala process var:\n", .{});
                var after_iterator = after_processes.processes.iterator();
                while (after_iterator.next()) |after_entry| {
                    const after_port = after_entry.key_ptr.*;
                    const after_process_info = after_entry.value_ptr.*;
                    std.debug.print("   🎯 Port {}: {s} (PID {})\n", .{ after_port, after_process_info.name, after_process_info.pid });
                }
            }
        }
    }
}
