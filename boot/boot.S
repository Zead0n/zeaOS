.code16

entry:
    // Initialize segments
    xor %ax, %ax
    mov %ax, %ds
    mov %ax, %ss

    // Remember dl
    mov %dl, boot_disk

    // Initialize stack
    mov $0x9c00, %ax
    mov %ax, %sp

    cli
    push %ds
    push %es

    // Enable A20
    in  $0x92, %al
    or  $2, %al
    out %al, $0x92

    // Enter protected mode
    lgdtw gdt_info
    mov %cr0, %eax
    or $1, %al
    mov %al, %cr0
    jmp pmode
pmode:
    // Setup unreal mode
    mov $0x10, %bx
    mov %bx, %ds
    mov %bx, %es

    // Return to real mode
    and $0xfe, %al
    mov %eax, %cr0
    jmp unrealmode
unrealmode:
    pop %es
    pop %ds

err_hang:
    jmp err_hang

gdt_start:
    .quad 0

gdt_code:
    .word 0xffff
    .word 0
    .byte 0
    .byte 0x9a
    .byte 0xcf
    .byte 0

gdt_data:
    .word 0xffff
    .word 0
    .byte 0
    .byte 0x92
    .byte 0xcf
    .byte 0

gdt_end:

gdt_info:
    .word gdt_end - get_start - 1
    .long gdt_start

boot_disk:
    .byte 0

.space 510-(.-entry)
.word  0xaa55
