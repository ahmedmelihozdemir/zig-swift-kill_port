const std = @import("std");
const types = @import("types.zig");
const ProcessMonitor = @import("process_monitor.zig").ProcessMonitor;
const AppConfig = types.AppConfig;
const StatusBarInfo = types.StatusBarInfo;
const ConsoleApp = @import("console_app.zig").ConsoleApp;

// TODO: Implement proper macOS system tray integration using Cocoa APIs
// For now, just run in console mode when GUI is requested
pub const TrayApp = struct {
    allocator: std.mem.Allocator,
    config: AppConfig,
    console_app: ConsoleApp,

    pub fn init(allocator: std.mem.Allocator, config: AppConfig) !TrayApp {
        const console_app = try ConsoleApp.init(allocator, config);

        return TrayApp{
            .allocator = allocator,
            .config = config,
            .console_app = console_app,
        };
    }

    pub fn deinit(self: *TrayApp) void {
        self.console_app.deinit();
    }

    pub fn run(self: *TrayApp) !void {
        std.log.info("GUI mode requested but not yet implemented", .{});
        std.log.info("Falling back to console mode...", .{});

        // For now, just run the console app
        try self.console_app.run();
    }

    // Placeholder methods for future implementation
    pub fn createStatusBarItem(self: *TrayApp) !void {
        _ = self;
        std.log.warn("Status bar creation not yet implemented", .{});
    }

    pub fn updateMenu(self: *TrayApp, info: StatusBarInfo) !void {
        _ = self;
        _ = info;
        std.log.debug("Menu update not yet implemented", .{});
    }

    pub fn showNotification(self: *TrayApp, title: []const u8, message: []const u8) void {
        _ = self;
        std.log.info("Notification: {s} - {s}", .{ title, message });
    }

    pub fn killAllProcesses(self: *TrayApp) !void {
        try self.console_app.process_monitor.killAllProcesses();
        self.showNotification("Port Kill", "All monitored processes terminated");
    }
};
