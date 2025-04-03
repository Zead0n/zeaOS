const console = @import("io/console.zig");

const MultibootHeader = packed struct {
    magic: u32,
    flags: u32,
    checksum: u32,
    padding: u32 = 0,
};

export const multiboot_header align(4) linksection(".multiboot") = multiboot: {
    const ALIGN = 1 << 0;
    const MEMINFO = 1 << 1;
    const MAGIC = 0x1BADB002;
    const FLAGS = ALIGN | MEMINFO;

    break :multiboot MultibootHeader{
        .magic = MAGIC,
        .flags = FLAGS,
        .checksum = -(MAGIC + FLAGS),
    };
};

var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;

export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ movl %[stack_top], %%esp
        \\ movl %%esp, %%ebp
        \\ call %[kmain:P]
        :
        : [stack_top] "i" (@as([*]align(16) u8, @ptrCast(&stack_bytes)) + @sizeOf(@TypeOf(stack_bytes))),
          [kmain] "X" (&kmain),
    );
}

export fn kmain() callconv(.C) noreturn {
    console.initialize();
    console.puts("Hello ZeaOS!");
    while (true) {}
}
