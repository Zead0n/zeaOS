const builtin = @import("builtin");

const platform = switch (builtin.cpu.arch) {
    .x86 => @import("x86/x86.zig"),
    else => unreachable,
};

pub usingnamespace platform;
