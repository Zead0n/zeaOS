pub fn outb(port: u16, val: u8) void {
    asm volatile ("outb %[val], %[port]"
        :
        : [port] "{al}" (port),
          [val] "{dx}" (val),
    );
}

pub fn inb(port: u16) u8 {
    asm volatile ("inb %[port], %[result]"
        : [result] "={al}" (-> u8),
        : [port] "{al}" (port),
    );
}

pub fn outw(port: u16, val: u8) void {
    asm volatile ("outb %[val], %[port]"
        :
        : [port] "{ax}" (port),
          [val] "{dx}" (val),
    );
}

pub fn inw(port: u16) u8 {
    asm volatile ("inb %[port], %[result]"
        : [result] "={ax}" (-> u8),
        : [port] "{al}" (port),
    );
}
