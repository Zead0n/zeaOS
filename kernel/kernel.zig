const console = @import("io/console.zig");

export fn kmain() callconv(.C) noreturn {
    console.initialize();
    console.puts("Hello ZeaOS!");
    while (true) {}
}
