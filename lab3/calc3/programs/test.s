.section .data
formatstr:	.asciz "%d
"
.section .bss
symbols:	 .fill 25, 4, 0

.section .text
.globl _start
_start:
	leal	symbols,%ebx
	push	$732
	movl	(%esp),%ecx
	movl	%ecx,0(%ebx)
	addl	$4,%esp
	push	$2684
	movl	(%esp),%ecx
	movl	%ecx,4(%ebx)
	addl	$4,%esp
L000:
	push	0(%ebx)
	push	4(%ebx)
	movl	4(%esp),%eax
	movl	(%esp),%ecx
	addl	$8,%esp
	cmpl	%ecx,%eax
	je	L001
	push	0(%ebx)
	push	4(%ebx)
	movl	4(%esp),%eax
	movl	(%esp),%ecx
	addl	$8,%esp
	cmpl	%ecx,%eax
	jle	L002
	push	0(%ebx)
	push	4(%ebx)
	movl	4(%esp),%eax
	subl	(%esp),%eax
	addl	$8,%esp
	pushl	%eax
	movl	(%esp),%ecx
	movl	%ecx,0(%ebx)
	addl	$4,%esp
	jmp	L003
L002:
	push	4(%ebx)
	push	0(%ebx)
	movl	4(%esp),%eax
	subl	(%esp),%eax
	addl	$8,%esp
	pushl	%eax
	movl	(%esp),%ecx
	movl	%ecx,4(%ebx)
	addl	$4,%esp
L003:
	jmp	L000
L001:
	push	0(%ebx)
	push	$formatstr
	call	printf
	addl	$8,%esp
	pushl	$0
	call	exit
