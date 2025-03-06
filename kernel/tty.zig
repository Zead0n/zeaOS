const arch = @import("arch.zig").internals;

pub const TTY = struct {
    write: fn ([]const u8) void,
};

var tty: TTY = undefined;

pub fn init() void {
    tty = arch.initTTY();
}
