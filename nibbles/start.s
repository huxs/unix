.set LENGTH, 5
.set APPLES, 5

.section .text
.globl _start
_start:

	push %ebp
	mov %esp, %ebp

	push $APPLES
	push $LENGTH
	call start_game
	add $8, %esp

	leave
	ret
	