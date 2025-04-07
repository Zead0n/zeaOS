.code16

print_string:
    pusha

print_loop:
    mov (%bx), %al
    cmp $0, %al
    je  print_done

    mov $0x0e, %ah
    int $0x10

    add $1, %bx
    jmp print_loop

print_done:
    popa
    ret

print_new_line:
    pusha

    mov $0x0e, %ah
    mov $0x0a, %al
    int $0x10
    mov $0x0d, %al
    int $0x10

    popa
    ret
