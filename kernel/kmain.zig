const console = @import("./console.zig");

export fn kmain() callconv(.C) noreturn {
    console.initialize();
    console.puts("Hello ZeaOS!");
    while (true) {}
}
