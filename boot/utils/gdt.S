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

gdtr:
    .word gdt_end - get_start - 1
    .long gdt_start
