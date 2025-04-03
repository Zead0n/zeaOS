const std = @import("std");

pub fn build(b: *std.Build) void {
    const zeaTarget = b.option(ZeaTarget, "arch", "Cpu architecture (Defaults to x86)") orelse ZeaTarget.x86;

    const target = b.resolveTargetQuery(zeaTarget.getTargetQuery());
    const optimize = b.standardOptimizeOption(.{});

    const boot_mod = b.addModule("boot", .{
        .target = target,
        .optimize = optimize,
    });
    boot_mod.addAssemblyFile(b.path("boot/x86/stage1/boot.S"));

    const boot_obj = b.addObject(.{
        .name = "boot.o",
        .root_module = boot_mod,
    });

    const boot_bin = b.addObjCopy(boot_obj.getEmittedBin(), .{
        .format = .bin,
        .basename = "boot.bin",
    });

    const boot_file = b.addInstallBinFile(boot_bin.getOutput(), "boot.bin");

    const boot_step = b.step("bootload", "Boot stuff");
    boot_step.dependOn(&boot_file.step);
}

const ZeaTarget = enum {
    x86,

    pub fn getTargetQuery(self: @This()) std.Target.Query {
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

        return targetQuery;
    }
};
