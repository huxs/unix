.section .text
.globl fact
.type fact, @function
fact:
        push %ebp
        movl %esp,%ebp
        movl 8(%ebp),%ecx
        cmpl $1,%ecx
        jle L0
        decl %ecx
        push %ecx
        call fact
        addl $4, %esp
        mull 8(%ebp)
        leave
        ret
L0:
        movl $1,%eax
        leave
        ret

.globl lntwo
.type lntwo, @function
lntwo:
        push %ebp
        movl %esp,%ebp
        movl $1,%edx
        movl 8(%ebp),%ecx
L1:
        shrl $1,%ecx
        cmpl $1,%ecx
        je L2
        incl %edx
        jmp L1
L2:
        movl %edx,%eax
        leave
        ret

.globl gcd
.type gcd, @function
gcd:
        push %ebp
        movl %esp,%ebp
        cmpl $0,12(%ebp)
        je L3
        movl 8(%ebp),%eax
        xorl %edx,%edx
        divl 12(%ebp)
        push %edx
        push 12(%ebp)
        call gcd
        addl $8,%esp
        leave
        ret
L3:
        movl 8(%ebp),%eax
        leave
        ret
