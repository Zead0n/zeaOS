const std = @import("std");
const fs = std.fs;

pub const ZeaTarget = enum {
    x86,

    pub fn getResolvedTarget(self: ZeaTarget, b: *std.Build) std.Build.ResolvedTarget {
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

        const targetQuery = switch (self) {
            .x86 => x86,
        };

        return b.resolveTargetQuery(targetQuery);
    }

    pub fn getArchMod(self: ZeaTarget, b: *std.Build) void {
        const archName = @tagName(self);
        const archPath = b.pathJoin(.{ "..", "arch", archName });

        return b.addModule("arch", .{ .root_source_file = archPath });
    }
};
