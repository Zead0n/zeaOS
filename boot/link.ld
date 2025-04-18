ENTRY(_start)

SECTIONS {
    . = 0x7c00;

    .text :
    {
        *(.text)
    }

    .rodata BLOCK(1) : ALIGN(1)
    {
        *(.rodata)
    }

    .data BLOCK(1) : ALIGN(1)
    {
        *(.data)
    }

    .bss BLOCK(1) : ALIGN(1)
    {
        *(COMMON)
        *(.bss)
    }
}
