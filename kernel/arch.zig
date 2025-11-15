const builtin = @import("builtin");

pub const platform = switch (builtin.cpu.arch) {
    .x86 => @import("./arch/x86/platform.zig"),
    else => @compileError("No lib for Architecture"),
};
