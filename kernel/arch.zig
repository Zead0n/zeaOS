const std = @import("std");
const builtin = @import("builtin");

const Arch = struct {
    init: fn () void,
};

pub const internals: Arch = switch (builtin.cpu.arch) {
    .x86 => @import("arch/x86/arch.zig"),
    else => unreachable,
};
