const std = @import("std");

const ZeaTarget = enum(u8) {
    x86,
};

pub fn targetOption(b: *std.Build) std.Target.Query {
    const x86 = blk: {
        var disabled_features = std.Target.Cpu.Feature.Set.empty;
        var enabled_features = std.Target.Cpu.Feature.Set.empty;

        disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.mmx));
        disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.sse));
        disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.sse2));
        disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.avx));
        disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.avx2));

        enabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.soft_float));

        break :blk std.Target.Query{
            .cpu_arch = .x86,
            .os_tag = .freestanding,
            .abi = .none,
            .cpu_features_sub = disabled_features,
            .cpu_features_add = enabled_features,
        };
    };

    const arch: ZeaTarget = b.option(ZeaTarget, "arch", "Cpu architecture") orelse ZeaTarget.x86;
    return switch (arch) {
        ZeaTarget.x86 => x86,
    };
}

pub fn optimizeOption(b: *std.Build) std.builtin.OptimizeMode {
    return b.standardOptimizeOption(.{});
}
