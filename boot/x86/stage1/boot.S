.code16

_start:

loop:
	jmp loop

.space 510-(.-_start)
.word  0xaa55
