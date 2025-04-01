const std = @import("std");
const zea = @import("zea.zig");

pub fn zeaTargetOption(b: *std.Build) zea.ZeaTarget {
    return b.option(zea.ZeaTarget, "arch", "Cpu architecture") orelse zea.ZeaTarget.x86;
}

pub fn optimizeOption(b: *std.Build) std.builtin.OptimizeMode {
    return b.standardOptimizeOption(.{});
}
