const std = @import("std");

const options = @import("build/options.zig");

pub fn build(b: *std.Build) void {
    const zeaTarget = options.zeaTargetOption(b);

    const target = zeaTarget.getResolvedTarget(b);
    const optimize = options.optimizeOption(b);

    const exeOptions = std.Build.ExecutableOptions{
        .name = "kernel.elf",
        .root_source_file = b.path("kernel/kmain.zig"),
        .target = target,
        .optimize = optimize,
        .code_model = .kernel,
    };

    const kernel = b.addExecutable(exeOptions);

    kernel.setLinkerScript(b.path("kernel/linker.ld"));
    b.installArtifact(kernel);

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.step);
}
