const std = @import("std");

/// Build configuration for Kill Port application
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the main executable (GUI/Tray mode)
    const exe = b.addExecutable(.{
        .name = "kill-port",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Create the console-only executable
    const console_exe = b.addExecutable(.{
        .name = "kill-port-console",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main_console.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Link system libraries for macOS
    if (target.result.os.tag == .macos) {
        exe.linkFramework("Cocoa");
        exe.linkFramework("AppKit");
        exe.linkSystemLibrary("c");

        console_exe.linkSystemLibrary("c");
    }

    // Install the executables
    b.installArtifact(exe);
    b.installArtifact(console_exe);

    // Create run commands
    const run_exe = b.addRunArtifact(exe);
    const run_console = b.addRunArtifact(console_exe);

    if (b.args) |args| {
        run_exe.addArgs(args);
        run_console.addArgs(args);
    }

    const run_step = b.step("run", "Run the GUI application");
    run_step.dependOn(&run_exe.step);

    const run_console_step = b.step("run-console", "Run the console application");
    run_console_step.dependOn(&run_console.step);

    // Unit tests for libraries
    const test_step = b.step("test", "Run unit tests");

    const lib_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib/types.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const monitor_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib/process_monitor.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const cli_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib/cli.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_lib_tests = b.addRunArtifact(lib_tests);
    const run_monitor_tests = b.addRunArtifact(monitor_tests);
    const run_cli_tests = b.addRunArtifact(cli_tests);

    test_step.dependOn(&run_lib_tests.step);
    test_step.dependOn(&run_monitor_tests.step);
    test_step.dependOn(&run_cli_tests.step);
}
