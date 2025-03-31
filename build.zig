const std = @import("std");

const options = @import("build/options.zig");

pub fn build(b: *std.Build) void {
    // var disabled_features = std.Target.Cpu.Feature.Set.empty;
    // var enabled_features = std.Target.Cpu.Feature.Set.empty;
    //
    // disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.mmx));
    // disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.sse));
    // disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.sse2));
    // disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.avx));
    // disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.avx2));
    //
    // enabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.soft_float));
    //
    // const target_query = std.Target.Query{
    //     .cpu_arch = .x86,
    //     .os_tag = .freestanding,
    //     .abi = .none,
    //     .cpu_features_sub = disabled_features,
    //     .cpu_features_add = enabled_features,
    // };

    const target = options.targetOption(b);
    const optimize = options.optimizeOption(b);

    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = b.path("kernel/kmain.zig"),
        .target = b.resolveTargetQuery(target),
        .optimize = optimize,
        .code_model = .kernel,
    });

    kernel.setLinkerScript(b.path("kernel/linker.ld"));
    b.installArtifact(kernel);

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.step);
}
