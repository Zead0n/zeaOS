    .code16

_start:

loop:
    jmp loop

    .fill 510-(.-_start), 1, 0
    .word 0xaa55
