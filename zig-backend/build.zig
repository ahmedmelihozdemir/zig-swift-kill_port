const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the main executable
    const exe = b.addExecutable(.{
        .name = "port-kill",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Create the console-only executable
    const console_exe = b.addExecutable(.{
        .name = "port-kill-console",
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
}
