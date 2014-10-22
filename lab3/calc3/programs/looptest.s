.section .data
formatstr:	.asciz "%d
"
.section .bss
symbols:	 .fill 25, 4, 0

.section .text
.globl _start
_start:
	leal	symbols,%ebx
	push	$100
	movl	(%esp),%ecx
	movl	%ecx,32(%ebx)
	addl	$4,%esp
L000:
	push	32(%ebx)
	push	$0
	movl	4(%esp),%eax
	movl	(%esp),%ecx
	addl	$8,%esp
	cmpl	%ecx,%eax
	js	L001
	push	32(%ebx)
	push	$formatstr
	call	printf
	addl	$8,%esp
	push	32(%ebx)
	push	$1
	movl	4(%esp),%eax
	subl	(%esp),%eax
	addl	$8,%esp
	pushl	%eax
	movl	(%esp),%ecx
	movl	%ecx,32(%ebx)
	addl	$4,%esp
	jmp	L000
L001:
	pushl	$0
	call	exit
