.section .text.boot
.global  _start
.code16

_start:
	jmp skip_bpb
nop

.space 64

skip_bpb:
	xor %ax, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %ss
	mov %ax, %fs
	mov %ax, %gs

	cld

	mov $0x7c00, %sp

a20:
	in   $92, %al
	test $2, %al
	jnz  after_a20
	or   $2, %al
	and  $0xfe, %al
	out  %al, $92

after_a20:

extention_check:
	mov $0x41, %ah
	mov $0x55aa, %bx
	int $0x13
	jnc extention_pass

	mov  $ext_fail_msg, %si
	call print
	jmp  _end

extention_pass:

stage_1:
	push %dx
	jmp  firstStageEntry

_end:
	hlt
	jmp _end

ext_fail_msg:
	.asciz "Extention check failed"

print:
	mov $0x0e, %ah

print_continue:
	lodsb
	cmp $0, %al
	je  print_done
	int $0x10
	jmp print_continue

print_done:
	ret
