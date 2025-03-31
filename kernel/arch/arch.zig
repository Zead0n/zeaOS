const std = @import("std");
const builtin = @import("builtin");

pub const Arch = struct {
    tty: struct {
        initialize: fn () void,
        clear: fn () void,
        puts: fn ([]const u8) void,
    },
};

pub const internals: Arch = switch (builtin.cpu.arch) {
    .x86 => @import("x86/x86.zig"),
    else => unreachable,
};
