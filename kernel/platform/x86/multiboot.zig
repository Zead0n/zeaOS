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
