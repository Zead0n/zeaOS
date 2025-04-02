const vga = @import("vga.zig");

var row: usize = 0;
var column: usize = 0;
var buffer = @as([*]volatile u16, @ptrFromInt(0xB8000));

pub fn initialize() void {
    clear();
}

pub fn clear() void {
    @memset(buffer[0..vga.VGA_SIZE], vga.vgaEntry(' ', vga.getColor()));
}

pub fn putCharAt(c: u8, new_color: u8, x: usize, y: usize) void {
    const index = y * vga.VGA_WIDTH + x;
    buffer[index] = vga.vgaEntry(c, new_color);
}

pub fn putChar(c: u8) void {
    putCharAt(c, vga.getColor(), column, row);
    column += 1;
    if (column == vga.VGA_WIDTH) {
        column = 0;
        row += 1;
        if (row == vga.VGA_HEIGHT)
            row = 0;
    }
}

pub fn puts(data: []const u8) void {
    for (data) |c|
        putChar(c);
}
