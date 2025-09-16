.code16

.global _start

_start:
	jmp _start

.space 510 - (. - _start)
.word  0xaa55
