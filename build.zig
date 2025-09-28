const std = @import("std");
const arch_util = @import("build/arch.zig");
const builder_util = @import("build/builder.zig");

const Arch = arch_util.Arch;
const Builder = builder_util.Builder;

pub fn build(b: *std.Build) void {
    const arch = b.option(Arch, "arch", "Cpu architecture (Defaults to x86)") orelse Arch.x86;
    const optimize = b.standardOptimizeOption(.{});

    const builder: Builder = .{
        .target = b.resolveTargetQuery(arch.getTargetQuery()),
        .optimize = optimize,
    };

    const bootloader = builder.buildBootloader(b);
    const kernel = builder.buildKernel(b);

    const bootloader_install = b.addInstallBinFile(bootloader.getEmittedBin(), bootloader.name);
    const kernel_install = b.addInstallArtifact(kernel, .{});

    const install_step = b.getInstallStep();
    install_step.dependOn(&bootloader_install.step);
    install_step.dependOn(&kernel_install.step);

    // Bootloader step
    const bootloader_step = b.step("bootloader", "Build the bootloader");
    bootloader_step.dependOn(&bootloader_install.step);

    // Kernel step
    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel_install.step);
}
