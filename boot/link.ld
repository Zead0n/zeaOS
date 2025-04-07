OUTPUT_FORMAT("binary")
phys = 0x7c00;

SECTIONS {
    . = 0x7c00;

    .text :
    {
        code = .;
        *(.text)
    }

    .rodata BLOCK(1) : ALIGN(1)
    {
        *(.rodata)
    }

    .data BLOCK(1) : ALIGN(1)
    {
        data = .;
    }

    .bss BLOCK(1) : ALIGN(1)
    {
        PROVIDE(bss_start = .);
        bss = .;
        *(COMMON)
        *(.bss)
        *(.stack)
        PROVIDE(bss_end = .);
    }

    end = .;

    /DISCARD/ :
    {
        *(.comment)
        *(.eh_frame)
        *(.note.gnu.build-id)
    }
}
