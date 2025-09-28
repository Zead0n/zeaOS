const std = @import("std");
const arch_util = @import("utils/arch.zig");
const builder_util = @import("utils/builder.zig");

const Arch = arch_util.Arch;
const Builder = builder_util.Builder;

pub fn build(b: *std.Build) void {
    const arch = b.option(Arch, "arch", "Cpu architecture (Defaults to x86)") orelse Arch.x86;
    const optimize = b.standardOptimizeOption(.{});

    const builder: Builder = .{
        .target = b.resolveTargetQuery(arch.getTargetQuery()),
        .optimize = optimize,
    };

    const kernel = builder.buildKernel(b);
    const iso = builder.buildGrubIso(b);

    // Kernel step
    const kernel_install = b.addInstallArtifact(kernel, .{});
    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel_install.step);

    // Install step
    const install_step = b.getInstallStep();
    install_step.dependOn(&iso.step);
}
