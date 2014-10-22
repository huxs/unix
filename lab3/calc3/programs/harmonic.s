.section .data
formatstr:	.asciz "%d
"
.section .bss
symbols:	 .fill 25, 4, 0

.section .text
.globl _start
_start:
	leal	symbols,%ebx
	push	$1000000
	movl	(%esp),%ecx
	movl	%ecx,52(%ebx)
	addl	$4,%esp
	push	$100000000
	movl	(%esp),%ecx
	movl	%ecx,72(%ebx)
	addl	$4,%esp
	push	$0
	movl	(%esp),%ecx
	movl	%ecx,0(%ebx)
	addl	$4,%esp
L000:
	push	52(%ebx)
	push	$0
	movl	4(%esp),%eax
	movl	(%esp),%ecx
	addl	$8,%esp
	cmpl	%ecx,%eax
	jle	L001
	push	0(%ebx)
	push	72(%ebx)
	push	52(%ebx)
	xorl	%edx,%edx
	movl	4(%esp),%eax
	idivl	(%esp)
	addl	$8,%esp
	pushl	%eax
	movl	4(%esp),%eax
	addl	(%esp),%eax
	addl	$8,%esp
	pushl	%eax
	movl	(%esp),%ecx
	movl	%ecx,0(%ebx)
	addl	$4,%esp
	push	52(%ebx)
	push	$1
	movl	4(%esp),%eax
	subl	(%esp),%eax
	addl	$8,%esp
	pushl	%eax
	movl	(%esp),%ecx
	movl	%ecx,52(%ebx)
	addl	$4,%esp
	jmp	L000
L001:
	push	0(%ebx)
	push	72(%ebx)
	push	$1000
	xorl	%edx,%edx
	movl	4(%esp),%eax
	idivl	(%esp)
	addl	$8,%esp
	pushl	%eax
	xorl	%edx,%edx
	movl	4(%esp),%eax
	idivl	(%esp)
	addl	$8,%esp
	pushl	%eax
	push	$formatstr
	call	printf
	addl	$8,%esp
	pushl	$0
	call	exit
